import { Inter, Fira_Code } from "next/font/google";
import "./globals.css";

const inter = Inter({
    variable: "--font-inter",
    subsets: ["latin"],
});

const firaCode = Fira_Code({
    variable: "--font-fira-code",
    subsets: ["latin"],
});

export const metadata = {
    title: "Keyless Kingdom",
    description: "Passwordless Cloud Federation",
};

export default function RootLayout({
    children,
}: Readonly<{
    children: React.ReactNode;
}>) {
    return (
        <html lang="en" className="dark">
            <body
                className={`${inter.variable} ${firaCode.variable} antialiased bg-void-black text-text-primary min-h-screen overflow-hidden font-sans`}
            >
                <div className="fixed inset-0 bg-[url('/grid.svg')] bg-center [mask-image:linear-gradient(180deg,white,rgba(255,255,255,0))] opacity-20 pointer-events-none"></div>
                {children}
            </body>
        </html>
    );
}
