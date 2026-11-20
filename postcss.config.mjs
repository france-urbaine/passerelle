import tailwindcss from "@tailwindcss/postcss"
import postcssNested from "postcss-nested"

// Since Tailwind 4.3.3, a rule without declarations of its own has its nested
// rules resolved by Tailwind before postcss-nested, following the CSS nesting
// spec: `.block { &__element {} }` compiles to `:is(.block)__element`, which
// matches nothing. Write such BEM selectors in full (`.block__element {}`).
const forbidBrokenBEMSelectors = {
  postcssPlugin: "forbid-broken-bem-selectors",
  OnceExit(root, { result }) {
    const selectors = []

    root.walkRules((rule) => {
      if (/:is\([^()]*\)[\w-]/.test(rule.selector)) selectors.push(rule.selector)
    })

    if (selectors.length > 0) {
      throw new Error(
        `Nested BEM selectors were not resolved in ${result.opts.from}:\n` +
        [...new Set(selectors)].map((selector) => `  ${selector}`).join("\n") +
        "\nWrite them in full (`.block__element`) instead of nesting them (`&__element`) " +
        "in a rule without declarations."
      )
    }
  }
}

export default {
  plugins: [
    tailwindcss,
    postcssNested,
    forbidBrokenBEMSelectors,
  ]
}
