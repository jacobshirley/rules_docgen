"""Internal documentation processing actions."""

load("@bazel_lib//lib:copy_to_directory.bzl", "copy_to_directory_bin_action")
load("@bazel_lib//lib:paths.bzl", "to_repository_relative_path")
load(":providers.bzl", "DocsLinkInfo", "DocsProviderInfo")

def _correct_repo_name(name):
    """Corrects the repository name by replacing '+' with ''.

    Args:
        name: The original repository name.

    Returns:
        The corrected repository name.
    """
    return name.replace("+", "")

def _join_path(current, new_path):
    if (new_path == ""):
        return current

    if (current == ""):
        return new_path
    else:
        return current + "/" + new_path

def docs_action_impl(ctx):
    """Implementation function for docs_action rule.

    Processes documentation files and generates output with proper linking and file dependencies.

    Args:
        ctx: The rule context.

    Returns:
        A list of providers including DefaultInfo and DocsProviderInfo.
    """

    copy_to_directory_bin = ctx.toolchains["@bazel_lib//lib:copy_to_directory_toolchain_type"].copy_to_directory_info.bin

    path = ctx.attr.rewrite_path or ""

    out_dir = ctx.attr.out or ctx.label.name
    outs = []
    files = [ctx.file.entrypoint] if ctx.file.entrypoint else []
    files += ctx.files.srcs + ctx.files.data

    entrypoint_file_path = to_repository_relative_path(ctx.file.entrypoint) if ctx.file.entrypoint else None

    resolved_nav = []
    repo_name = _correct_repo_name(ctx.label.repo_name)

    for key, value in ctx.attr.nav.items():
        nav_element = {}

        # This is all a bit ugly. Essentially what we're trying to do is:
        # 1. Determine the repository name of the target providing the nav element
        # 2. Allow the user to override the path with rewrite_path
        # 3. Build the correct path to the entrypoint
        nav_repo_name = _correct_repo_name(key.label.repo_name)

        _subpath = ""
        title = ""
        subtitle = ""
        entrypoint = ""
        subnav = []
        is_external = False

        if (DocsProviderInfo in key):
            title = value if value and value != "" else key[DocsProviderInfo].title
            subtitle = key[DocsProviderInfo].title
            _subpath = key[DocsProviderInfo].path

            if (nav_repo_name != repo_name):
                _subpath = _subpath or nav_repo_name

            _entrypoint = key[DocsProviderInfo].entrypoint
            _subnav = key[DocsProviderInfo].nav

            if (len(_subnav) > 0):
                subnav = _subnav

            if (_entrypoint):
                entrypoint = _entrypoint
        elif (DocsLinkInfo in key):
            is_external = True
            title = value if value and value != "" else key[DocsLinkInfo].title
            entrypoint = key[DocsLinkInfo].url if key[DocsLinkInfo].url != "" else key[DocsLinkInfo].entrypoint if key[DocsLinkInfo].entrypoint != "" else key.label.name
        else:
            title = value if value and value != "" else key.label.name
            entrypoint = to_repository_relative_path(key.files.to_list()[0])
        subpath = _join_path(path or repo_name, _subpath)

        if (entrypoint):
            nav_element[title] = _join_path(subpath, entrypoint) if not is_external else entrypoint

        if (len(subnav) > 0):
            nav_element_main = {}
            if (entrypoint):
                nav_element_main[subtitle] = nav_element[title]

            nav_element[title] = ([nav_element_main] if entrypoint else []) + subnav

        resolved_nav.append(nav_element)
        nav_path = ""

        if (DocsProviderInfo in key):
            other_files = key[DocsProviderInfo].files
            nav_path = key[DocsProviderInfo].path
        elif (DocsLinkInfo in key):
            other_files = key[DocsLinkInfo].files
            nav_path = key[DocsLinkInfo].path
        else:
            other_files = key.files.to_list()

        nav_path = nav_path or nav_repo_name

        if (nav_path != "" and nav_path != repo_name):
            out_folder = ctx.actions.declare_directory(nav_path)

            copy_to_directory_bin_action(
                ctx = ctx,
                copy_to_directory_bin = copy_to_directory_bin,
                name = "_" + nav_repo_name,
                files = other_files,
                dst = out_folder,
                include_external_repositories = ["*"],
                allow_overwrites = True,
            )

            files.append(out_folder)
        else:
            files += other_files

    if ((not ctx.attr.is_index) and len(files) > 0):
        out_folder = ctx.actions.declare_directory(out_dir)

        copy_to_directory_bin_action(
            ctx = ctx,
            copy_to_directory_bin = copy_to_directory_bin,
            name = "_" + ctx.label.name,
            files = files,
            dst = out_folder,
            include_external_repositories = ["*"],
            allow_overwrites = True,
        )

        outs.append(out_folder)

    return [
        DefaultInfo(
            files = depset(outs),
        ),
        DocsProviderInfo(
            path = path,
            title = ctx.attr.title or ctx.label.name,
            files = files,
            entrypoint = entrypoint_file_path if entrypoint_file_path else None,
            nav = resolved_nav,
            out_dir = out_dir,
        ),
        DocsLinkInfo(
            path = path,
            title = ctx.attr.title,
            files = files,
            entrypoint = entrypoint_file_path if entrypoint_file_path else None,
        ),
    ]

docs_action = rule(
    implementation = docs_action_impl,
    doc = """
    Processes documentation files and generates output with proper linking and file dependencies.
    """,
    attrs = {
        "title": attr.string(
            doc = "The title of the navigation element",
        ),
        "entrypoint": attr.label(
            doc = "The entrypoint file for the documentation",
            allow_single_file = True,
        ),
        "srcs": attr.label_list(
            doc = "The files that are part of the documentation",
            allow_files = True,
        ),
        "data": attr.label_list(
            doc = "The data files that are part of the documentation",
            allow_files = True,
        ),
        "out": attr.string(
            doc = "The output directory for the documentation",
        ),
        "deps": attr.label_list(
            doc = "The dependencies of the documentation",
            providers = [DocsProviderInfo],
        ),
        "nav": attr.label_keyed_string_dict(
            doc = "Sub navigation elements",
            allow_files = True,
            providers = [DocsLinkInfo],
        ),
        "rewrite_path": attr.string(
            doc = "The path prefix to rewrite documentation files to",
            default = "",
        ),
        "is_index": attr.bool(
            doc = "Whether this docs action is the index",
            default = False,
        ),
    },
    toolchains = [
        "@bazel_lib//lib:copy_to_directory_toolchain_type",
        "@bazel_lib//lib:coreutils_toolchain_type",
    ],
)
