// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

// include syntax highlight dependency
import hljs from "highlight.js"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

function updateLineNumbers(value) {
  const lineNumberText = document.querySelector("#line-numbers")
  if (!lineNumberText) return;
  const lines = value.split("\n")

  const numbers = lines.map((_, index) => index + 1).join("\n") + "\n"

  lineNumberText.value = numbers
}

let Hooks = {};
Hooks.UpdateLineNumbers = {
  mounted() {
    const lineNumberText = document.querySelector("#line-numbers")

    this.el.addEventListener("input", () => {
      updateLineNumbers(this.el.value)
    })

    this.el.addEventListener("scroll", () => {
      lineNumberText.scrollTop = this.el.scrollTop
    })

    this.el.addEventListener("keydown", (e) => {
      if (e.key == "Tab") {
        e.preventDefault();
        // get cursor position
        var start = this.el.selectionStart;
        var end = this.el.selectionEnd;
        // insert tab character
        this.el.value = this.el.value.substring(0, start) + "\t" + this.el.value.substring(end)
        // update cursor position
        this.el.selectionStart = this.el.selectionEnd + 1
      }
    })

    this.handleEvent("clear-textarea", () => {
      this.el.value = ""
      lineNumberText.value = "1\n"
    })

    updateLineNumbers(this.el.value)
  }
};

Hooks.Highlight = {
  mounted() {
    let name = this.el.getAttribute("data-name");
    let codeBlock = this.el.querySelector("pre code");
    if (name && codeBlock) {
      codeBlock.className = codeBlock.className.replace(/language-\S+/g, "");
      codeBlock.classList.add(`language-${this.getSyntaxType(name)}`);
      trimmed = this.trimCodeBlock(codeBlock)
      hljs.highlightElement(trimmed);
      updateLineNumbers(trimmed.textContent)
    }
  },

  getSyntaxType(name) {
    const syntaxSet = {
      "txt": "text", "exs": "elixir", "ex": "elixir", "json": "json", "html": "html", "heex": "html", "js": "javascript", 
      "erl": "erlang", "py": "python", "dart": "dart", "h": "c", "c": "c", "php": "php", "cs": "csharp",
      "hpp": "cpp", "cpp": "cpp", "rb": "ruby", "go": "go", "rs": "rust", "java": "java", "sh": "bash",
      "yml": "yaml", "yaml": "yaml", "css": "css", "xml": "xml", "sql": "sql"
    }

    if (name === "Dockerfile") {
      return "dockerfile";
    }

    let extension = name.split(".").pop();
    return syntaxSet[extension] || "text";
  },

  trimCodeBlock(codeBlock) {
    const lines = codeBlock.textContent.split("\n");
    if (lines.length > 2) {
      lines.shift();
      lines.pop();
    }
    codeBlock.textContent = lines.join("\n");
    return codeBlock;
  }
}

Hooks.CopyToClipboard = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      const textToCopy = this.el.getAttribute("clipboard-data-gist");
      if (textToCopy) {
        navigator.clipboard.writeText(textToCopy)
        .then(() => {
          console.log("Gist copied to clipboard")
        })
        .catch(err => {
          console.error("Failed to copy text: ", err)
        })
      }
    })
  }
}

Hooks.ToggleEdit = {
  mounted() {
    this.el.addEventListener("click", () => {
      let edit = document.getElementById("edit-section")
      let syntax = document.getElementById("syntax-section")
      if (edit && syntax) {
        edit.style.display = "block";
        syntax.style.display = "none";
      }
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

