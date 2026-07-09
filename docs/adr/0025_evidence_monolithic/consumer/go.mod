module example.com/consumer

go 1.26.4

replace ocm.software/open-component-model/bindings/go => ../../../../bindings/go

require ocm.software/open-component-model/bindings/go v0.0.0-00010101000000-000000000000

require (
	github.com/cyberphone/json-canonicalization v0.0.0-20241213102144-19d51d7fe467 // indirect
	github.com/santhosh-tekuri/jsonschema/v6 v6.0.2 // indirect
	go.yaml.in/yaml/v2 v2.4.3 // indirect
	golang.org/x/text v0.40.0 // indirect
	sigs.k8s.io/yaml v1.6.0 // indirect
)
