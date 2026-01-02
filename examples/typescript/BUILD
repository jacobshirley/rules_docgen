load("@npm//:typedoc/package_json.bzl", "bin")
load("@rules_docs//docgen:defs.bzl", "docs", "docs_index")
load("@npm//:defs.bzl", "npm_link_all_packages")
npm_link_all_packages(name = "node_modules")

# similar to
# https://github.com/JakubAndrysek/mkdocs-typedoc/blob/8552f568152f48cd790b414d502ffa14193e4dd5/typedoc/plugin.py#L71-L93
# TODO: this should run as an aspect over the ts_library target instead
bin.typedoc(
    name = "typedoc",
    srcs = [
        "//:typedoc.json",
        "//:tsconfig.json",
        "//:API.md",
    ] + glob(["src/**/*.ts"]),
    chdir = package_name(),
    out_dirs = ["_docs"],
    args = [
        "--out",
        "_docs",
        "--readme",
        "$(execpath //:API.md)",
    ],
)

docs(
    name = "api_docs",
    data = [":typedoc"],
    entry = "API.md",
    readme_content = "TypeScript with typedoc",
    readme_header_links = {
        ":typedoc": "API Reference",
    },
    visibility = ["//visibility:public"],
)

docs(
    name = "index",
    srcs = [
        ":api_docs",
    ],
    nav = {
        ":api_docs": "API Reference",
    },
    title = "TypeScript with typedoc",
    visibility = ["//visibility:public"],
)
