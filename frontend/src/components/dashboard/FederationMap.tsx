import React from 'react';
import { motion } from 'framer-motion';
import { Github, Cloud, ShieldCheck, Lock, Server } from 'lucide-react';
import { TokenFlow } from '../ui/TokenFlow';

export function FederationMap() {
    return (
        <div className="relative w-full h-[500px] bg-black/20 rounded-3xl border border-white/5 overflow-hidden backdrop-blur-sm">
            {/* Background Grid */}
            <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-[0.05]" />

            {/* Central Trust Hub */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-20">
                <motion.div
                    initial={{ scale: 0.9, opacity: 0 }}
                    animate={{ scale: 1, opacity: 1 }}
                    transition={{ duration: 0.8 }}
                    className="relative w-48 h-48"
                >
                    {/* Outer Ring */}
                    <div className="absolute inset-0 rounded-full border border-indigo-500/30 animate-[spin_10s_linear_infinite]" />
                    <div className="absolute inset-4 rounded-full border border-purple-500/30 animate-[spin_15s_linear_infinite_reverse]" />

                    {/* Core */}
                    <div className="absolute inset-0 flex items-center justify-center">
                        <div className="w-24 h-24 rounded-full bg-gradient-to-br from-indigo-600 to-purple-700 shadow-[0_0_50px_rgba(79,70,229,0.4)] flex items-center justify-center relative z-10">
                            <ShieldCheck className="w-10 h-10 text-white" />
                        </div>
                        {/* Pulse Effect */}
                        <div className="absolute w-24 h-24 rounded-full bg-indigo-500/20 animate-ping" />
                    </div>
                </motion.div>
            </div>

            {/* GitHub Node (Source) */}
            <div className="absolute left-20 top-1/2 -translate-y-1/2 z-20">
                <motion.div
                    initial={{ x: -50, opacity: 0 }}
                    animate={{ x: 0, opacity: 1 }}
                    transition={{ delay: 0.2 }}
                    className="p-6 rounded-2xl bg-[#0D1117] border border-white/10 shadow-xl relative group"
                >
                    <div className="absolute -inset-0.5 bg-gradient-to-r from-zinc-700 to-zinc-800 rounded-2xl opacity-0 group-hover:opacity-100 transition duration-500 blur opacity-20" />
                    <div className="relative flex flex-col items-center gap-3">
                        <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center border border-white/10">
                            <Github className="w-8 h-8 text-white" />
                        </div>
                        <div className="text-center">
                            <h3 className="text-white font-cal text-lg">GitHub Actions</h3>
                            <p className="text-xs text-zinc-500">OIDC Issuer</p>
                        </div>
                    </div>
                </motion.div>
            </div>

            {/* Cloud Providers (Targets) */}
            <div className="absolute right-20 top-1/2 -translate-y-1/2 flex flex-col gap-8 z-20">
                {[
                    { name: 'AWS', color: 'text-[#FF9900]', bg: 'bg-[#FF9900]/10', border: 'border-[#FF9900]/20' },
                    { name: 'Azure', color: 'text-[#0078D4]', bg: 'bg-[#0078D4]/10', border: 'border-[#0078D4]/20' },
                    { name: 'GCP', color: 'text-[#4285F4]', bg: 'bg-[#4285F4]/10', border: 'border-[#4285F4]/20' }
                ].map((provider, i) => (
                    <motion.div
                        key={provider.name}
                        initial={{ x: 50, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + (i * 0.1) }}
                        className={`p-4 rounded-xl bg-black/40 backdrop-blur-md border ${provider.border} flex items-center gap-4 w-48`}
                    >
                        <div className={`w-10 h-10 rounded-lg ${provider.bg} flex items-center justify-center`}>
                            <Cloud className={`w-5 h-5 ${provider.color}`} />
                        </div>
                        <div>
                            <h4 className="text-white font-medium">{provider.name}</h4>
                            <p className="text-[10px] text-zinc-500">Federated</p>
                        </div>
                    </motion.div>
                ))}
            </div>

            {/* Connection Lines & Flows */}
            <svg className="absolute inset-0 w-full h-full pointer-events-none z-10">
                <defs>
                    <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="0%">
                        <stop offset="0%" stopColor="rgba(255,255,255,0.1)" />
                        <stop offset="50%" stopColor="rgba(99,102,241,0.5)" />
                        <stop offset="100%" stopColor="rgba(255,255,255,0.1)" />
                    </linearGradient>
                </defs>

                {/* Line from GitHub to Center */}
                <motion.path
                    d="M 180 250 L 400 250"
                    stroke="url(#grad1)"
                    strokeWidth="2"
                    fill="none"
                    initial={{ pathLength: 0 }}
                    animate={{ pathLength: 1 }}
                    transition={{ duration: 1.5, ease: "easeInOut" }}
                />

                {/* Lines from Center to Providers */}
                <motion.path
                    d="M 550 250 L 750 150"
                    stroke="rgba(255,255,255,0.1)"
                    strokeWidth="1"
                    fill="none"
                />
                <motion.path
                    d="M 550 250 L 750 250"
                    stroke="rgba(255,255,255,0.1)"
                    strokeWidth="1"
                    fill="none"
                />
                <motion.path
                    d="M 550 250 L 750 350"
                    stroke="rgba(255,255,255,0.1)"
                    strokeWidth="1"
                    fill="none"
                />
            </svg>

            {/* Animated Tokens */}
            <div className="absolute inset-0 pointer-events-none z-15">
                <TokenFlow className="absolute top-1/2 left-[25%] -translate-y-1/2 w-32" />
                <TokenFlow className="absolute top-[35%] right-[25%] w-32 rotate-[-20deg]" delay={1} />
                <TokenFlow className="absolute top-1/2 right-[25%] -translate-y-1/2 w-32" delay={1.5} />
                <TokenFlow className="absolute bottom-[35%] right-[25%] w-32 rotate-[20deg]" delay={2} />
            </div>
        </div>
    );
}
