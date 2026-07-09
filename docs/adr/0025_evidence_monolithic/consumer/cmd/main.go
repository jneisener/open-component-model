package main

import (
	"fmt"

	descriptorv2 "ocm.software/open-component-model/bindings/go/descriptor/v2"
	"ocm.software/open-component-model/bindings/go/runtime"
)

func main() {
	s := runtime.NewScheme()
	descriptorv2.MustAddToScheme(s)
	fmt.Println("descriptor/v2 types:", s.GetTypes())
}
