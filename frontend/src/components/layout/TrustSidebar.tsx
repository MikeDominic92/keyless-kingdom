import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Shield, Activity, Settings, FileText, GitBranch, Lock, LogOut } from 'lucide-react';
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
        <div className="w-64 h-[calc(100vh-2rem)] glass-panel border-r-0 flex flex-col fixed left-4 top-4 z-50 rounded-2xl">
            <div className="h-20 flex items-center px-6 border-b border-white/10">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-tr from-cyber-cyan to-cyber-purple flex items-center justify-center border border-white/10 shadow-[0_0_10px_rgba(6,182,212,0.3)] mr-3">
                    <Lock className="w-6 h-6 text-white" />
                </div>
                <span className="font-orbitron font-bold text-lg tracking-tight text-white">Keyless<span className="text-cyber-cyan neon-text-cyan">Kingdom</span></span>
            </div>

            <nav className="flex-1 p-4 space-y-2">
                {navItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <Link
                            key={item.href}
                            href={item.href}
                            className={cn(
                                "flex items-center px-3 py-3 rounded-xl text-sm font-medium transition-all duration-300 group",
                                isActive
                                    ? "bg-cyber-cyan/10 text-cyber-cyan border border-cyber-cyan/20 shadow-[0_0_10px_rgba(6,182,212,0.1)]"
                                    : "text-gray-400 hover:bg-white/5 hover:text-white hover:pl-4"
                            )}
                        >
                            <item.icon className={cn(
                                "w-5 h-5 mr-3 transition-colors",
                                isActive ? "text-cyber-cyan" : "text-gray-500 group-hover:text-white"
                            )} />
                            {item.name}
                        </Link>
                    );
                })}
            </nav>

            <div className="p-4 border-t border-white/10 space-y-2">
                <div className="p-4 rounded-xl bg-black/40 border border-white/5">
                    <div className="flex items-center gap-2 mb-2">
                        <div className="w-2 h-2 rounded-full bg-cyber-green animate-pulse shadow-[0_0_5px_#10b981]" />
                        <span className="text-xs font-medium text-cyber-green font-mono">System Healthy</span>
                    </div>
                    <p className="text-xs text-gray-500">OIDC Federation Active</p>
                </div>
                <button className="flex items-center w-full px-3 py-2 rounded-lg text-sm font-medium text-red-400 hover:bg-red-500/10 hover:text-red-300 transition-colors">
                    <LogOut className="w-5 h-5 mr-3" />
                    Sign Out
                </button>
            </div>
        </div>
    );
}

