module.exports = {
  env: {
    es2021: true,
    node: true,
  },

  parserOptions: {
    ecmaVersion: 2022,
    sourceType: "script",
  },

  extends: [
    "eslint:recommended",
    "google",
  ],

  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],

    "require-jsdoc": "off",
    "valid-jsdoc": "off",
    "indent": "off",
    "object-curly-spacing": "off",
    "operator-linebreak": "off",
    "quote-props": "off",
    "max-len": "off",
  },

  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],

  globals: {},
};
