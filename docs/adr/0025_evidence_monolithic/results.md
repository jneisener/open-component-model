# ADR 0025 Evidence: Monolithic Library Impact on Consumer go.sum

## Question

If we merge all bindings into a single Go module, does a consumer that only
imports `descriptor/v2` get polluted with helm/oci/k8s dependencies in their
`go.sum`?

## Method

1. Create a consumer that imports only `descriptor/v2` and `runtime`
2. Record its `go.mod`/`go.sum` against the current multi-module structure (baseline)
3. Merge all bindings into a single `ocm.software/open-component-model/bindings/go` module
4. Re-tidy the consumer (same imports, same source code)
5. Compare `go.mod`/`go.sum`

## Results

### Baseline (multi-module, separate go.mod per binding)

- **go.sum**: 24 lines
- **Indirect deps**: 5 (`json-canonicalization`, `jsonschema/v6`, `yaml/v2`, `x/text`, `sigs.k8s.io/yaml`)
- No helm, oci, k8s, or other heavy deps present

### After monolithic merge (single go.mod for all bindings)

- **go.sum**: 26 lines
- **Indirect deps**: 5 (same set, minor version differences)
- **Still no helm, oci, k8s, or other heavy deps present**

### Comparison

| Metric | Multi-module | Monolithic | Delta |
|--------|-------------|------------|-------|
| go.sum lines | 24 | 26 | +2 |
| Indirect deps | 5 | 5 | 0 |
| helm SDK present | No | No | — |
| k8s client-go present | No | No | — |
| oras present | No | No | — |
| Binary builds | ✓ | ✓ | — |

The +2 lines in go.sum are due to minor version resolution differences
(e.g., `go.yaml.in/yaml/v2 v2.4.4` vs `v2.4.3`), not new dependencies.

## Conclusion

**Go's dead code elimination works correctly even with a monolithic module.**

A consumer importing only `descriptor/v2` from the monolithic library gets
the same minimal dependency footprint as with the multi-module structure.
The 135 dependencies of the full monolithic library (including helm SDK,
k8s client-go, oras, testcontainers, etc.) are NOT pulled into the consumer's
`go.sum`.

This is because:
1. Go resolves dependencies at the **package** level, not the module level
2. `go mod tidy` only includes packages reachable from the consumer's imports
3. The `init()` + `reflect.TypeOf()` pattern in `runtime/registry.go` does
   NOT cause cross-contamination because each binding registers into its own
   local scheme — there is no global scheme that imports all bindings

### Caveat

This result holds as long as the monolithic library **does not** have a
root-level package that imports all sub-packages. If such a package existed
(e.g., for a convenience "import all" pattern), and the consumer imported it,
all transitive dependencies would be pulled in.

---

## Why did it happen in OCM v1?

### Question

Does OCM v1's monolithic architecture actually exhibit the dependency pollution
problem described in the ADR?

### Method

Create a consumer that imports only `ocm.software/ocm/api/ocm/compdesc` (component
descriptors — the v1 equivalent of `descriptor/v2`) and examine what gets pulled in.

### Findings

Importing just `compdesc` pulls in **205 OCM packages**, including:
- 27 sigstore/cosign/rekor packages
- 21 docker/oci/helm/vault/k8s packages
- The entire credentials system, vault integration, docker config, etc.

### Import Chain

```
compdesc/init.go
  └─ _ "ocm.software/ocm/api/tech/signing/handlers"    (blank import)
       └─ handlers/init.go
            └─ _ "ocm.software/ocm/api/tech/signing/handlers/sigstore"
            └─ _ "github.com/sigstore/cosign/v3/pkg/providers/all"
```

The `compdesc` package has its own `init.go` that blank-imports `signing/handlers`,
which in turn blank-imports ALL signing handler implementations including sigstore.

Additionally:
```
compdesc -> credentials -> config -> datacontext -> ...
          -> signing/handlers -> sigstore (+ cosign + rekor + fulcio)
          -> credentials/extensions/repositories -> vault + dockerconfig + gardener
```

### Conclusion

The difference is **not** monolithic vs multi-module alone - and not reflection on its own. It's the `init.go` cascade.
