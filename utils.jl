using Makie.LaTeXStrings

function env_examplefigure(com, _)
    content = Franklin.content(com)
    lang, ex_name, code = Franklin.parse_fenced_block(content, false)
    if lang != "julia"
        error("Code block needs to be julia. Found: $(lang), $(typeof(lang))")
    end

    kwargs = eval(Meta.parse("Dict(pairs((;" * Franklin.content(com.braces[1]) * ")))"))

    name = pop!(kwargs, :name, "example_" * string(hash(content)))
    svg = pop!(kwargs, :svg, false)

    rest_kwargs_str = join(("$key = $(repr(val))" for (key, val) in kwargs), ", ")

    pngfile = "$name.png"
    svgfile = "$name.svg"

    # add the generated png name to the list of examples for this page, which
    # can later be used to assemble an overview page
    # for some reason franklin needs a pair as the content?
    pngsvec, _ = get!(Franklin.LOCAL_VARS, "examplefigures_png", String[] => Vector{String})
    push!(pngsvec, pngfile)

    str = """
    ```julia:example_figure
    using CairoMakie, Makie.LaTeXStrings # hide
    __result = begin # hide
        $code
    end # hide
    save(joinpath(@OUTPUT, "$pngfile"), __result; $rest_kwargs_str) # hide
    $(svg ? "save(joinpath(@OUTPUT, \"$svgfile\"), __result; $rest_kwargs_str) # hide" : "")
    nothing # hide
    ```
    ~~~
    <a id="$name">
    ~~~
    \\fig{$name.$(svg ? "svg" : "png")}
    ~~~
    </a>
    ~~~
    """
    return str
end
