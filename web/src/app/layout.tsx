import type { Metadata } from "next";
import localFont from "next/font/local";
import { Analytics } from "@vercel/analytics/react";
import "./globals.css";

const geistSans = localFont({
  src: "./fonts/GeistVF.woff",
  variable: "--font-geist-sans",
  weight: "100 900",
});
const geistMono = localFont({
  src: "./fonts/GeistMonoVF.woff",
  variable: "--font-geist-mono",
  weight: "100 900",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://www.heardle.fun"),
  title: {
    default: "Heardle.fun - Music Quiz Game | Guess Songs from Audio Clips",
    template: "%s | Heardle.fun",
  },
  description:
    "Play the ultimate music quiz game! Search for any artist and test your knowledge by guessing their songs from short audio clips. The faster you guess, the more points you earn! Free music trivia game featuring thousands of artists.",
  keywords: [
    "heardle",
    "music quiz",
    "guess the song",
    "song guessing game",
    "music trivia",
    "heardle alternative",
    "audio quiz",
    "music game",
    "song quiz",
    "music knowledge test",
    "free music game",
    "artist quiz",
  ],
  authors: [{ name: "Jed Patterson" }],
  creator: "Jed Patterson",
  publisher: "Heardle.fun",
  formatDetection: {
    email: false,
    address: false,
    telephone: false,
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://www.heardle.fun",
    siteName: "Heardle.fun",
    title: "Heardle.fun - Music Quiz Game | Guess Songs from Audio Clips",
    description:
      "Play the ultimate music quiz game! Search for any artist and test your knowledge by guessing their songs from short audio clips. Free music trivia featuring thousands of artists.",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "Heardle.fun - Music Quiz Game",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    site: "@heardle_fun",
    creator: "@jedpatterson",
    title: "Heardle.fun - Music Quiz Game",
    description:
      "Play the ultimate music quiz game! Guess songs from audio clips and test your music knowledge.",
    images: ["/og-image.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
        <Analytics />
      </body>
    </html>
  );
}
