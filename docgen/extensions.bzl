"""Extensions for bzlmod.

Installs a docgen toolchain.
Every module can define a toolchain version under the default name, "docgen".
The latest of those versions will be selected (the rest discarded),
and will always be registered by rules_docgen.

Additionally, the root module can define arbitrarily many more toolchain versions under different
names (the latest version will be picked for each name) and can register them as it sees fit,
effectively overriding the default named toolchain due to toolchain resolution precedence.
"""

docgen_mkdocs = tag_class(attrs = {
    "mkdocs_version": attr.string(doc = "Explicit version of mkdocs.", mandatory = False, default = "1.5.2"),
})

def _toolchain_extension(module_ctx):
    mkdocs = []
    for mod in module_ctx.modules:
        for toolchain in mod.tags.mkdocs:
            mkdocs.append(toolchain.mkdocs_version)

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
