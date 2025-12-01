'use client';

import React, { useState } from 'react';
import { KingdomShell } from '@/components/layout/KingdomShell';
import { motion, AnimatePresence } from 'framer-motion';
import { Github, Cloud, Key, Lock, ShieldCheck, ArrowRight, Server } from 'lucide-react';

export default function ArchitectureViz() {
    const [activeStep, setActiveStep] = useState<number | null>(null);

    const steps = [
        {
            id: 1,
            title: 'Workflow Trigger',
            description: 'GitHub Action starts and requests an OIDC token from GitHub\'s OIDC Provider.',
            icon: Github,
            color: 'text-white',
            bg: 'bg-zinc-800'
        },
        {
            id: 2,
            title: 'Token Issuance',
            description: 'GitHub signs a JWT (JSON Web Token) containing claims about the workflow (repo, branch, etc.).',
            icon: Key,
            color: 'text-indigo-400',
            bg: 'bg-indigo-900/20'
        },
        {
            id: 3,
            title: 'Cloud Authentication',
            description: 'The workflow sends the JWT to the Cloud Provider (AWS/Azure/GCP) to assume a role.',
            icon: Cloud,
            color: 'text-blue-400',
            bg: 'bg-blue-900/20'
        },
        {
            id: 4,
            title: 'Trust Validation',
            description: 'Cloud Provider validates the JWT signature and checks if the claims match the Trust Policy.',
            icon: ShieldCheck,
            color: 'text-emerald-400',
            bg: 'bg-emerald-900/20'
        },
        {
            id: 5,
            title: 'Access Granted',
            description: 'Temporary cloud credentials are returned to the GitHub Action workflow.',
            icon: Lock,
            color: 'text-amber-400',
            bg: 'bg-amber-900/20'
        }
    ];

    return (
        <KingdomShell>
            <div className="h-[calc(100vh-8rem)] flex flex-col">
                <div className="mb-8">
                    <h1 className="text-3xl font-cal text-white mb-2">Architecture Visualizer</h1>
                    <p className="text-zinc-400">Interactive walkthrough of the OIDC federation flow.</p>
                </div>

                <div className="flex-1 grid grid-cols-1 lg:grid-cols-3 gap-8">
                    {/* Interactive Diagram */}
                    <div className="lg:col-span-2 bg-black/20 border border-white/10 rounded-3xl relative overflow-hidden backdrop-blur-sm flex items-center justify-center">
                        <div className="absolute inset-0 bg-[url('/grid.svg')] opacity-[0.05]" />

                        {/* Flow Visualization */}
                        <div className="relative w-full max-w-2xl h-96">
                            {/* GitHub Side */}
                            <motion.div
                                className={`absolute left-0 top-1/2 -translate-y-1/2 p-6 rounded-2xl border transition-all duration-500 ${activeStep === 1 || activeStep === 2 ? 'bg-white/10 border-white/20 shadow-[0_0_30px_rgba(255,255,255,0.1)]' : 'bg-black/40 border-white/5 opacity-50'
                                    }`}
                            >
                                <Github className="w-12 h-12 text-white mb-2" />
                                <p className="font-cal text-lg text-white">GitHub</p>
                            </motion.div>

                            {/* Cloud Side */}
                            <motion.div
                                className={`absolute right-0 top-1/2 -translate-y-1/2 p-6 rounded-2xl border transition-all duration-500 ${activeStep === 3 || activeStep === 4 || activeStep === 5 ? 'bg-indigo-500/10 border-indigo-500/20 shadow-[0_0_30px_rgba(99,102,241,0.2)]' : 'bg-black/40 border-white/5 opacity-50'
                                    }`}
                            >
                                <Cloud className="w-12 h-12 text-indigo-400 mb-2" />
                                <p className="font-cal text-lg text-indigo-300">Cloud Provider</p>
                            </motion.div>

                            {/* Animated Token/Connection */}
                            <div className="absolute left-32 right-32 top-1/2 -translate-y-1/2 h-1 bg-white/5 rounded-full overflow-hidden">
                                <AnimatePresence>
                                    {activeStep && (
                                        <motion.div
                                            key={activeStep}
                                            initial={{ x: '-100%' }}
                                            animate={{ x: '100%' }}
                                            transition={{ duration: 2, repeat: Infinity, ease: "linear" }}
                                            className="w-1/3 h-full bg-gradient-to-r from-transparent via-indigo-500 to-transparent"
                                        />
                                    )}
                                </AnimatePresence>
                            </div>

                            {/* Central Validation Node */}
                            <motion.div
                                className={`absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 w-24 h-24 rounded-full border flex items-center justify-center z-10 transition-all duration-500 ${activeStep === 4 ? 'bg-emerald-500/20 border-emerald-500 shadow-[0_0_30px_rgba(16,185,129,0.4)] scale-110' : 'bg-black/60 border-white/10'
                                    }`}
                            >
                                <ShieldCheck className={`w-10 h-10 transition-colors ${activeStep === 4 ? 'text-emerald-400' : 'text-zinc-600'}`} />
                            </motion.div>
                        </div>
                    </div>

                    {/* Step Controls */}
                    <div className="space-y-4 overflow-y-auto pr-2">
                        {steps.map((step) => (
                            <button
                                key={step.id}
                                onClick={() => setActiveStep(step.id)}
                                className={`w-full text-left p-4 rounded-xl border transition-all duration-300 group ${activeStep === step.id
                                        ? 'bg-white/5 border-indigo-500/50 ring-1 ring-indigo-500/50'
                                        : 'bg-transparent border-white/5 hover:bg-white/5 hover:border-white/10'
                                    }`}
                            >
                                <div className="flex items-start gap-4">
                                    <div className={`p-3 rounded-lg ${step.bg} transition-transform group-hover:scale-105`}>
                                        <step.icon className={`w-5 h-5 ${step.color}`} />
                                    </div>
                                    <div>
                                        <h3 className={`font-medium mb-1 transition-colors ${activeStep === step.id ? 'text-white' : 'text-zinc-400 group-hover:text-zinc-200'}`}>
                                            {step.id}. {step.title}
                                        </h3>
                                        <p className="text-sm text-zinc-500 leading-relaxed">
                                            {step.description}
                                        </p>
                                    </div>
                                </div>
                            </button>
                        ))}

                        {activeStep && (
                            <button
                                onClick={() => setActiveStep(null)}
                                className="w-full py-3 mt-4 text-sm text-zinc-500 hover:text-white transition-colors border border-dashed border-white/10 rounded-xl hover:bg-white/5"
                            >
                                Reset Animation
                            </button>
                        )}
                    </div>
                </div>
            </div>
        </KingdomShell>
    );
}
