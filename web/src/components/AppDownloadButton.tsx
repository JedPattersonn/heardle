"use client";

import Link from "next/link";
import posthog from "posthog-js";

interface AppDownloadButtonProps {
  location: string;
  className?: string;
  children: React.ReactNode;
}

export function AppDownloadButton({
  location,
  className,
  children,
}: AppDownloadButtonProps) {
  const handleAppDownloadClick = () => {
    posthog.capture("app_download_clicked", {
      location,
      app_store_url:
        "https://apps.apple.com/app/apple-store/id6748839500?pt=127292799&ct=Heardle.fun&mt=8",
    });
  };

  return (
    <Link
      href="https://apps.apple.com/app/apple-store/id6748839500?pt=127292799&ct=Heardle.fun&mt=8"
      target="_blank"
      rel="noopener noreferrer"
      className={className}
      onClick={handleAppDownloadClick}
    >
      {children}
    </Link>
  );
}
