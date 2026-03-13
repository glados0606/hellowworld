"use client";

interface ButtonProps {
  onClick?: () => void;
  type?: "button" | "submit";
  disabled?: boolean;
  loading?: boolean;
  variant?: "primary" | "secondary" | "ghost" | "danger";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
  className?: string;
  title?: string;
}

export default function Button({
  onClick,
  type = "button",
  disabled = false,
  loading = false,
  variant = "primary",
  size = "md",
  children,
  className = "",
  title,
}: ButtonProps) {
  const base =
    "inline-flex items-center justify-center font-medium rounded-lg " +
    "transition-all duration-150 focus:outline-none focus:ring-2 focus:ring-offset-2 " +
    "disabled:cursor-not-allowed";

  const variants = {
    primary:
      "bg-violet-600 text-white hover:bg-violet-700 active:bg-violet-800 " +
      "focus:ring-violet-500 disabled:bg-violet-300 shadow-sm",
    secondary:
      "bg-white text-gray-700 border border-gray-300 hover:bg-gray-50 " +
      "active:bg-gray-100 focus:ring-violet-500 disabled:bg-gray-100 disabled:text-gray-400 shadow-sm",
    ghost:
      "text-gray-600 hover:text-gray-900 hover:bg-gray-100 active:bg-gray-200 " +
      "focus:ring-gray-400 disabled:text-gray-300",
    danger:
      "bg-red-600 text-white hover:bg-red-700 active:bg-red-800 " +
      "focus:ring-red-500 disabled:bg-red-300 shadow-sm",
  };

  const sizes = {
    sm: "px-3 py-1.5 text-xs gap-1.5",
    md: "px-4 py-2 text-sm gap-2",
    lg: "px-6 py-3 text-base gap-2",
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      title={title}
      className={`${base} ${variants[variant]} ${sizes[size]} ${className}`}
    >
      {loading && (
        <svg
          className="animate-spin h-4 w-4 shrink-0"
          fill="none"
          viewBox="0 0 24 24"
          aria-hidden="true"
        >
          <circle
            className="opacity-25"
            cx="12" cy="12" r="10"
            stroke="currentColor" strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      )}
      {children}
    </button>
  );
}
