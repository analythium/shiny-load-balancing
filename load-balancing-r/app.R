library(shiny)
library(bslib)

ui <- fixedPage(
    theme = bs_theme(version = 5), # force BS v5
    markdown("
## Sticky load balancing test in R-Shiny

The purpose of this app is to determine if HTTP requests made by the client are
correctly routed back to the same R process where the session resides. It
is only useful for testing deployments that load balance traffic across more
than one R process.

If this test fails, it means that sticky load balancing is not working, and
certain Shiny functionality (like file upload/download or server-side selectize)
are likely to randomly fail.
    "),
    tags$div(
        class = "card",
        tags$div(
            class = "card-body font-monospace",
            tags$div("Attempts: ", tags$span(id="count", "0")),
            tags$div("Status: ", tags$span(id="status")),
            uiOutput("out")
        )
    )
)

server <- function(input, output, session) {

    url <- session$registerDataObj(
        name   = "test",
        data   = list(),
        filter = function(data, req) {
            message("INFO: ",
                req$REMOTE_ADDR, ":",
                req$REMOTE_PORT,
                " - ",
                req$REQUEST_METHOD,
                " /session/",
                session$token,
                req$PATH_INFO,
                req$QUERY_STRING)
            shiny:::httpResponse(
                status = 200L,
                content_type = "text/html; charset=UTF-8",
                content = "OK",
                headers = list("Cache-Control" = "no-cache"))
        }
    )
    output$out <- renderUI({
        message("Incoming connection")
        tags$script(
            sprintf('
    const url = "%s";
    const count_el = document.getElementById("count");
    const status_el = document.getElementById("status");
    let count = 0;
    async function check_url() {{
        count_el.innerHTML = ++count;
        try {{
            const resp = await fetch(url);
            if (!resp.ok) {{
                status_el.innerHTML = "Failure!";
                return;
            }} else {{
                status_el.innerHTML = "In progress";
            }}
        }} catch(e) {{
            status_el.innerHTML = "Failure!";
            return;
        }}

        if (count === 100) {{
            status_el.innerHTML = "Test complete";
            return;
        }}

        setTimeout(check_url, 10);
    }}
    check_url();
            ', url)
        )
    })

}

app <- shinyApp(ui, server)
