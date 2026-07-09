module example.com/consumer

go 1.26.4

replace (
	ocm.software/open-component-model/bindings/go/descriptor/v2 => ../../../../bindings/go/descriptor/v2
	ocm.software/open-component-model/bindings/go/runtime => ../../../../bindings/go/runtime
)

require (
	ocm.software/open-component-model/bindings/go/descriptor/v2 v2.0.0-00010101000000-000000000000
	ocm.software/open-component-model/bindings/go/runtime v0.0.8
)

require (
	github.com/cyberphone/json-canonicalization v0.0.0-20241213102144-19d51d7fe467 // indirect
	github.com/santhosh-tekuri/jsonschema/v6 v6.0.2 // indirect
	go.yaml.in/yaml/v2 v2.4.4 // indirect
	golang.org/x/text v0.37.0 // indirect
	sigs.k8s.io/yaml v1.6.0 // indirect
)
