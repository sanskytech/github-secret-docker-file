import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Access to your GitHub Secrets in Dockerfile",
  description: "Access to your GitHub Secrets in Dockerfile",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
