import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        soap: {
          s: { light: "#EDE9FE", DEFAULT: "#8B5CF6", dark: "#5B21B6" },
          o: { light: "#DBEAFE", DEFAULT: "#3B82F6", dark: "#1E40AF" },
          a: { light: "#FEF3C7", DEFAULT: "#F59E0B", dark: "#B45309" },
          p: { light: "#D1FAE5", DEFAULT: "#10B981", dark: "#047857" },
          unclassified: { light: "#F3F4F6", DEFAULT: "#6B7280", dark: "#374151" },
        },
      },
      fontFamily: {
        sans: [
          "Pretendard",
          "-apple-system",
          "BlinkMacSystemFont",
          "system-ui",
          "sans-serif",
        ],
        mono: ["JetBrains Mono", "Fira Code", "monospace"],
      },
    },
  },
  plugins: [],
};

export default config;
