PLANTUML_DOCKER=plantuml/plantuml
DIAGRAMS_DIR=docs/architecture/c4
OUTPUT_DIR=rendered

render-diagrams:
	mkdir -p $(PWD)/$(DIAGRAMS_DIR)/$(OUTPUT_DIR)
	docker run --rm -v $(PWD)/$(DIAGRAMS_DIR):/workspace $(PLANTUML_DOCKER) \
		-tpng -o $(OUTPUT_DIR) /workspace/*.puml