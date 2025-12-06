"""Extensions for bzlmod.

Installs a docgen toolchain.
Every module can define a toolchain version under the default name, "docgen".
The latest of those versions will be selected (the rest discarded),
and will always be registered by rules_docgen.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

load(":repositories.bzl", "mkdocs_repository")

docgen_mkdocs = tag_class(attrs = {
    "name": attr.string(
        doc = "The name of this mkdocs toolchain. Only used in the root module.",
        mandatory = False,
        default = "mkdocs",
    ),
    "pypi_hub": attr.label(doc = "Name of the pip repository hub that contains mkdocs", mandatory = False, default = "@default_pypi"),
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
                name = mod.name or "mkdocs",
                pypi_hub = toolchain.pypi_hub,
                plugins = toolchain.plugins,
            )
            
            # Only process the first mkdocs tag (they should all be the same in root module)
            break

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
