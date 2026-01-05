# rules_docs

Bazel rules for managing documentation and static site generation.

> **Notice:** _This package is in alpha (< 1.0) and the API may change without notice until it reaches a stable release._

## Features

-   **Bazel targets**: Manage your documentation as Bazel targets
-   **MkDocs**: Manage MkDocs (and plugins) using `rules_python` and generate static sites
-   **Git integration**: Add last updated timestamps from git history
-   **Linting**: Tested with https://vale.sh/ for linting prose, using rules_lint

## Installation

### Using Bzlmod (MODULE.bazel)

Add the following to your `MODULE.bazel`:

```python
bazel_dep(name = "rules_docs", version = "0.0.0")  # Use latest version
```

Optionally, you can specify a requirements.txt file for MkDocs and its plugins. This is needed if you want to use MkDocs plugins.

```python
bazel_dep(name = "rules_python", version = "1.7.0")

# Configure Python and pip dependencies
pip = use_extension("@rules_python//python/extensions:pip.bzl", "pip")
pip.parse(
    hub_name = "pypi",
    python_version = "3.11",
    requirements_lock = "//:requirements.txt",
)
use_repo(pip, "pypi")

# Configure docgen with mkdocs plugins
docgen = use_extension("@rules_docs//docgen:extensions.bzl", "docgen")
docgen.mkdocs(
    plugins = [
        "mkdocs-glightbox",
        "mkdocs-material",
        "mkdocs-table-reader-plugin",
    ],
    pypi_hub = "@pypi",
)
use_repo(docgen, "mkdocs")
```

See [requirements.txt](requirements.txt) for an example requirements file.

To install linting support, see the rules_lint documentation for running Vale over the targets created by rules_docs:
https://registry.bazel.build/docs/aspect_rules_lint#lint-vale-bzl

### Using WORKSPACE

Workspace is not supported. Please use Bzlmod.

## Setting up custom MkDocs or MkDocs plugins

### 1. Follow installation instructions above

Make sure to include `rules_python` and configure pip dependencies as shown above.

### 2. Create requirements.txt

Create a `requirements.in` file with mkdocs and desired plugins:

```
mkdocs
mkdocs-material
mkdocs-glightbox
mkdocs-table-reader-plugin
pymdown-extensions
```

Then add a `BUILD.bazel` target to compile the requirements:

```python
load("@rules_python//python:pip.bzl", "compile_pip_requirements")

compile_pip_requirements(
    name = "requirements",
    src = "requirements.in",
    requirements_txt = "requirements.txt",
)
```

To create/update the `requirements.txt`, run:

```bash
bazel build //:requirements.update
```

### 3. Create mkdocs template (mkdocs.tpl.yaml)

Create a `mkdocs.tpl.yaml` file with your mkdocs configuration:

```yaml
site_name: My Documentation
repo_url: https://github.com/yourusername/yourrepo
docs_dir: docs
site_dir: site
theme:
    name: material
    palette:
        - media: '(prefers-color-scheme)'
          primary: custom
          accent: custom
          toggle:
              icon: material/brightness-auto
              name: Switch to light mode
        - media: '(prefers-color-scheme: light)'
          scheme: default
          primary: custom
          accent: custom
          toggle:
              icon: material/brightness-7
              name: Switch to dark mode
        - media: '(prefers-color-scheme: dark)'
          scheme: slate
          primary: custom
          accent: custom
          toggle:
              icon: material/brightness-4
              name: Switch to system preference
    features:
        - navigation.path
plugins:
    - search
    - table-reader
    - glightbox
markdown_extensions:
    - tables
    - pymdownx.superfences:
          custom_fences:
              - name: mermaid
                class: mermaid
                format: '!!python/name:pymdownx.superfences.fence_code_format'
    - pymdownx.snippets:
          check_paths: true
          base_path:
              - '!relative'
```

### 4. Create BUILD.bazel with documentation rules

```python
load("@rules_docs//docgen:defs.bzl", "docs", "docs_index", "docs_link")
load("@mkdocs//:defs.bzl", "mkdocs_build", "mkdocs_config", "mkdocs_serve")

# Define external links
docs_link(
    name = "docs_link",
    title = "External Link",
    url = "https://example.com",
    visibility = ["//visibility:public"],
)

# Create additional documentation sections
docs(
    name = "other_docs",
    entrypoint = "other-info.md",
    readme_content = "This is some other documentation content.",
)

# Create nested navigation
docs_index(
    name = "sub_nav",
    nav = {
        ":docs_link": "External Link",
        "other-info.md": "Other Info",
        ":other_docs": "Other Docs",
    },
    title = "Sub Navigation",
)

# Main documentation configuration
docs(
    name = "docs",
    nav = {
        "README.md": "Home",
        ":docs_link": "External Link",
        "other-info.md": "Other Info",
        ":other_docs": "Other Docs",
        ":sub_nav": "",  # Will use the title as the link text
    },
    readme_header_links = {
        ":docs_link": "",
    },
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
```

## Usage

### Building Documentation

Build the static documentation site:

```bash
bazel build //:mkdocs
```

The built site will be in `bazel-bin/site/`.

### Serving Documentation Locally

Serve the documentation with live reload (recommended with ibazel):

```bash
# With ibazel for auto-reload
ibazel run //:mkdocs.serve

# Without ibazel
bazel run //:mkdocs.serve
```

Then open your browser to http://localhost:8000

### Navigation Structure

The `nav` attribute in the `docs` rule creates the navigation structure:

-   **Markdown files**: `"path/to/file.md": "Display Name"`
-   **External links**: `":link_target": "Display Name"` (references a `docs_link` target)
-   **Other docs**: `":docs_target": "Display Name"` (references another `docs` target)
-   **Nested nav**: `":index_target": ""` (references a `docs_index` target; empty string uses the index's title)

## Example Project

See the complete working example in [e2e/smoke/](e2e/smoke/README.md) directory, which demonstrates:

-   Both Bzlmod (MODULE.bazel) and WORKSPACE setups
-   Complete BUILD.bazel configuration
-   Navigation with external links and nested sections
-   MkDocs configuration with Material theme
-   Development server setup

Also see language- or framework-specific examples in the examples/ folder.

The examples/typescript folder also demonstrates how Vale can be setup to lint markdown prose.

## Advanced Features

### Git Last Updated Timestamps

Add last updated timestamps from git history to your documentation:

```python
load("@rules_docs//docgen:defs.bzl", "markdown_add_last_updated", "git_last_updated_timestamps")

git_last_updated_timestamps(
    name = "git_last_updated_timestamps",
    srcs = glob(["**/*.md"]),
    out = "last_updated.json",
)

markdown_add_last_updated(
    name = "docs_with_last_updated",
    docs = ":docs",
    last_updated_json = ":git_last_updated_timestamps",
    out_dir = "last_updated_docs",
)
```

See [e2e/git_last_updated/](e2e/git_last_updated/) for a complete example.
