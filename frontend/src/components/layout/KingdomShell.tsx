import React from 'react';
import { TrustSidebar } from './TrustSidebar';
import { FederationHeader } from './FederationHeader';

interface KingdomShellProps {
    children: React.ReactNode;
}

export function KingdomShell({ children }: KingdomShellProps) {
    return (
        <div className="min-h-screen bg-[#09090B] text-zinc-100 font-sans selection:bg-indigo-500/30">
            {/* Background Effects */}
            <div className="fixed inset-0 z-0 pointer-events-none overflow-hidden">
                <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[50%] bg-indigo-900/10 rounded-full blur-[120px]" />
                <div className="absolute bottom-[-20%] right-[-10%] w-[50%] h-[50%] bg-purple-900/10 rounded-full blur-[120px]" />
                <div className="absolute top-[40%] left-[40%] w-[20%] h-[20%] bg-blue-900/5 rounded-full blur-[100px]" />
                <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-[0.03]" />
            </div>

            <TrustSidebar />
            <FederationHeader />

            <main className="ml-64 p-8 relative z-10 min-h-[calc(100vh-4rem)]">
                <div className="max-w-7xl mx-auto">
                    {children}
                </div>
            </main>
        </div>
    );
}
