import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Shield, Activity, Settings, FileText, GitBranch, Lock } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
    { name: 'Federation Overview', href: '/', icon: Activity },
    { name: 'Provider Config', href: '/config', icon: Settings },
    { name: 'Workflow Integration', href: '/workflow', icon: GitBranch },
    { name: 'Security Audit', href: '/audit', icon: FileText },
    { name: 'Architecture Viz', href: '/architecture', icon: Shield },
];

export function TrustSidebar() {
    const pathname = usePathname();

    return (
        <div className="w-64 border-r border-white/10 bg-black/40 backdrop-blur-xl h-screen fixed left-0 top-0 flex flex-col z-50">
            <div className="p-6 flex items-center gap-3 border-b border-white/5">
                <div className="w-8 h-8 rounded-lg bg-indigo-500/20 flex items-center justify-center border border-indigo-500/50">
                    <Lock className="w-5 h-5 text-indigo-400" />
                </div>
                <span className="font-cal text-xl text-white tracking-wide">Keyless Kingdom</span>
            </div>

            <nav className="flex-1 p-4 space-y-2">
                {navItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                "flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-300 group relative overflow-hidden",
                                isActive
                                    ? "bg-indigo-500/10 text-indigo-300 border border-indigo-500/20"
                                    : "text-zinc-400 hover:text-white hover:bg-white/5"
                            )}
                        >
                            {isActive && (
                                <div className="absolute left-0 top-0 bottom-0 w-1 bg-indigo-500 shadow-[0_0_10px_rgba(99,102,241,0.5)]" />
                            )}
                            <item.icon className={cn("w-5 h-5 transition-colors", isActive ? "text-indigo-400" : "group-hover:text-indigo-300")} />
                            <span className="font-medium">{item.name}</span>
                        </Link>
                    );
                })}
            </nav>

            <div className="p-4 border-t border-white/5">
                <div className="p-4 rounded-xl bg-gradient-to-br from-indigo-900/20 to-purple-900/20 border border-indigo-500/20">
                    <div className="flex items-center gap-2 mb-2">
                        <div className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse" />
                        <span className="text-xs font-medium text-emerald-400">System Healthy</span>
                    </div>
                    <p className="text-xs text-zinc-500">OIDC Federation Active</p>
                </div>
            </div>
        </div>
    );
}
