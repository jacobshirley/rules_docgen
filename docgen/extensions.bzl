"""Extensions for bzlmod.
"""

load(":repositories.bzl", "mkdocs_repository")

docgen_mkdocs = tag_class(attrs = {
    "name": attr.string(
        doc = "The name of this mkdocs toolchain. Only used in the root module.",
        mandatory = False,
        default = "mkdocs",
    ),
    "pypi_hub": attr.label(doc = "Name of the pip repository hub that contains mkdocs", mandatory = False, default = "@rules_docs__default_pypi"),
    "plugins": attr.string_list(doc = "List of mkdocs plugins to install", mandatory = False, default = []),
})

def _toolchain_extension(module_ctx):
    # Collect all requirements across modules
    for mod in module_ctx.modules:
        if (not mod.is_root):
            continue
        for toolchain in mod.tags.mkdocs:
            # Create mkdocs wrapper repository
            mkdocs_repository(
                name = toolchain.name,
                pypi_hub = toolchain.pypi_hub,
                plugins = toolchain.plugins,
            )

    return module_ctx.extension_metadata(
        reproducible = True,
    )

docgen = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"mkdocs": docgen_mkdocs},
    # Mark the extension as OS and architecture independent to simplify the
    # lock file. An independent module extension may still download OS- and
    # arch-dependent files, but it should download the same set of files
    # regardless of the host platform.
    os_dependent = False,
    arch_dependent = False,
)
