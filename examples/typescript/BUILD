load("@npm//:defs.bzl", "npm_link_all_packages")
load("@npm//:typedoc/package_json.bzl", "bin")
load("@rules_docs//docgen:defs.bzl", "docs", "docs_link", "markdown")

npm_link_all_packages(name = "node_modules")

markdown(
    name = "api_md",
    output = "API.md",
    readme_content = "# TypeScript with typedoc",
    readme_header_links = {
        # Pass the docs_link as a key to correctly link to the entrypoint
        ":typedoc_link": "API Reference",
    },
    title = "API Reference",
)

# similar to
# https://github.com/JakubAndrysek/mkdocs-typedoc/blob/8552f568152f48cd790b414d502ffa14193e4dd5/typedoc/plugin.py#L71-L93
# TODO: this should run as an aspect over the ts_library target instead
bin.typedoc(
    name = "typedoc",
    srcs = [
        "//:api_md",
        "//:tsconfig.json",
        "//:typedoc.json",
    ] + glob(["src/**/*.ts"]),
    args = [
        "--out",
        # Need to workaround the issue of when this is called from a different repo
        "_docs",
        "--readme",
        "API.md",
    ],
    # TODO: this should work without this repo_name() workaround when https://github.com/aspect-build/rules_js/pull/2344 is released
    chdir = "external/{}".format(repo_name()) if repo_name() != "" else package_name(),
    out_dirs = ["_docs"],
)

# Wrap the typedoc output in a docs_link to be used in the docs target
# This provides an entrypoint
docs_link(
    name = "typedoc_link",
    entrypoint = "_docs/index.html",
)

docs(
    name = "api_docs",
    # Depend on typedoc here instead of in docs_link to avoid circular dependencies
    srcs = [
        ":typedoc",
        ":typedoc_link",
    ],
    entrypoint = ":api_md",
)

docs(
    name = "index",
    nav = {
        ":api_docs": "API Reference",
    },
    title = "TypeScript with typedoc",
    visibility = ["//visibility:public"],
)
