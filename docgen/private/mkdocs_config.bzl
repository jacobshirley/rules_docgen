
def _mkdocs_config_impl(ctx):
    docs = ctx.attr.docs[DocsProviderInfo]

    base = ctx.file.mkdocs_base
    out = ctx.actions.declare_file(ctx.label.name + ".mkdocs.yml")

    root_nav_folder = ctx.attr.root_nav_folder
    if (root_nav_folder and (not root_nav_folder.endswith("/"))):
        root_nav_folder = root_nav_folder + "/"

    nav_json = json.encode(docs.nav)
    nav = nav_json.replace(root_nav_folder, "") if root_nav_folder else nav_json

    # Write the mkdocs.yml file
    ctx.actions.run_shell(
        inputs = [base],
        outputs = [out],
        progress_message = "Generating mkdocs.yml from %s" % base.short_path,
        command = "echo 'nav: {nav}' | cat - {input} > {output}".format(
            nav = nav,
            input = base.path,
            output = out.path,
        ),
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
    ]

mkdocs_config = rule(
    implementation = _mkdocs_config_impl,
    attrs = {
        "title": attr.string(
            doc = "The title of the site",
        ),
        "docs": attr.label(
            doc = "The docs to include in the site",
            providers = [DocsProviderInfo],
        ),
        "mkdocs_base": attr.label(
            doc = "The base mkdocs.yml file",
            allow_single_file = [".yaml", ".yml"],
            mandatory = True,
        ),
        "root_nav_folder": attr.string(
            doc = "The root nav folder",
            default = "",
        ),
    },
)