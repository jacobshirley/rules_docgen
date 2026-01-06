
load("@rules_docs//docgen:defs.bzl", "docs")
load("@mkdocs//:defs.bzl", "mkdocs_build", "mkdocs_config", "mkdocs_serve")
load("@rules_python//python:pip.bzl", "compile_pip_requirements")

compile_pip_requirements(
    name = "requirements",
    src = "pyproject.toml",
    requirements_txt = "requirements.txt",
)

docs(
    name = "other_docs",
    entry = "api-reference.md",
    data = ["openapi.yaml"],
    readme_content = "API Reference",
)

# Main documentation configuration
docs(
    name = "docs",
    nav = {
        "README.md": "Home",
        ":other_docs": "API Reference (Redoc)",
    },
    rewrite_path = "examples/swagger",
    visibility = ["//visibility:public"],
)

# Generate mkdocs configuration
mkdocs_config(
    name = "mkdocs_config",
    docs = ":docs",
    mkdocs_base = "mkdocs.tpl.yaml",
)

# Build documentation site
mkdocs_build(
    name = "mkdocs",
    config = ":mkdocs_config",
    docs = [":docs"],
    site_dir = "site",
    visibility = ["//visibility:public"],
)

# Serve documentation locally for development
# Recommended: run with ibazel for auto-reload on changes
mkdocs_serve(
    name = "mkdocs.serve",
    config = ":mkdocs_config",
    docs = [":docs"],
    visibility = ["//visibility:public"],
)