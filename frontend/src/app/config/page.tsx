'use client';

import React, { useState } from 'react';
import { KingdomShell } from '@/components/layout/KingdomShell';
import { FederationButton } from '@/components/ui/FederationButton';
import { ProviderBadge } from '@/components/ui/ProviderBadge';
import { Check, Copy, ArrowRight, Shield, Cloud, Terminal } from 'lucide-react';
import { motion } from 'framer-motion';

export default function ProviderConfig() {
    const [step, setStep] = useState(1);
    const [selectedProvider, setSelectedProvider] = useState<'aws' | 'gcp' | 'azure' | null>(null);

    return (
        <KingdomShell>
            <div className="max-w-4xl mx-auto space-y-8">
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-cal text-white mb-2">Provider Configuration</h1>
                        <p className="text-zinc-400">Establish trust between GitHub and your cloud environment.</p>
                    </div>
                </div>

                {/* Progress Steps */}
                <div className="flex items-center justify-between relative">
                    <div className="absolute left-0 top-1/2 w-full h-0.5 bg-white/10 -z-10" />
                    {[
                        { num: 1, label: 'Select Provider' },
                        { num: 2, label: 'Configure Trust' },
                        { num: 3, label: 'Verify Access' }
                    ].map((s) => (
                        <div key={s.num} className="flex flex-col items-center gap-2 bg-[#09090B] px-4">
                            <div className={`w-10 h-10 rounded-full flex items-center justify-center border-2 transition-colors ${step >= s.num
                                    ? 'border-indigo-500 bg-indigo-500/20 text-indigo-400'
                                    : 'border-zinc-700 bg-zinc-900 text-zinc-500'
                                }`}>
                                {step > s.num ? <Check className="w-5 h-5" /> : <span className="font-mono">{s.num}</span>}
                            </div>
                            <span className={`text-sm font-medium ${step >= s.num ? 'text-white' : 'text-zinc-500'}`}>
                                {s.label}
                            </span>
                        </div>
                    ))}
                </div>

                {/* Step Content */}
                <div className="bg-black/20 border border-white/10 rounded-2xl p-8 backdrop-blur-sm min-h-[400px]">
                    {step === 1 && (
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="space-y-6"
                        >
                            <h2 className="text-xl font-cal text-white">Choose your Cloud Provider</h2>
                            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                                {[
                                    { id: 'aws', name: 'AWS IAM', icon: Cloud, color: 'hover:border-[#FF9900]/50 hover:bg-[#FF9900]/5' },
                                    { id: 'azure', name: 'Azure AD', icon: Shield, color: 'hover:border-[#0078D4]/50 hover:bg-[#0078D4]/5' },
                                    { id: 'gcp', name: 'Google Cloud', icon: Terminal, color: 'hover:border-[#4285F4]/50 hover:bg-[#4285F4]/5' },
                                ].map((p) => (
                                    <button
                                        key={p.id}
                                        onClick={() => setSelectedProvider(p.id as any)}
                                        className={`p-6 rounded-xl border border-white/10 bg-white/5 flex flex-col items-center gap-4 transition-all group ${selectedProvider === p.id ? 'border-indigo-500 bg-indigo-500/10 ring-1 ring-indigo-500' : p.color
                                            }`}
                                    >
                                        <ProviderBadge provider={p.id as any} />
                                        <span className="text-lg font-medium text-white">{p.name}</span>
                                    </button>
                                ))}
                            </div>
                            <div className="flex justify-end mt-8">
                                <FederationButton
                                    disabled={!selectedProvider}
                                    onClick={() => setStep(2)}
                                    provider={selectedProvider || 'aws'}
                                >
                                    Continue Configuration
                                </FederationButton>
                            </div>
                        </motion.div>
                    )}

                    {step === 2 && (
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="space-y-6"
                        >
                            <h2 className="text-xl font-cal text-white">Configure Trust Policy</h2>
                            <div className="grid grid-cols-2 gap-8">
                                <div className="space-y-4">
                                    <div>
                                        <label className="block text-sm font-medium text-zinc-400 mb-1">GitHub Organization</label>
                                        <input type="text" className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-2 text-white focus:border-indigo-500 focus:outline-none" placeholder="e.g., my-org" />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-zinc-400 mb-1">Repository Name</label>
                                        <input type="text" className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-2 text-white focus:border-indigo-500 focus:outline-none" placeholder="e.g., my-repo" />
                                    </div>
                                    <div>
                                        <label className="block text-sm font-medium text-zinc-400 mb-1">Branch (Optional)</label>
                                        <input type="text" className="w-full bg-white/5 border border-white/10 rounded-lg px-4 py-2 text-white focus:border-indigo-500 focus:outline-none" placeholder="main" />
                                    </div>
                                </div>
                                <div className="bg-[#0D1117] rounded-xl p-4 border border-white/10 font-mono text-xs text-zinc-300 overflow-hidden">
                                    <div className="flex items-center justify-between mb-2 pb-2 border-b border-white/10">
                                        <span className="text-zinc-500">Generated Policy Preview</span>
                                        <Copy className="w-3 h-3 text-zinc-500 cursor-pointer hover:text-white" />
                                    </div>
                                    <pre className="text-emerald-400">
                                        {`{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:my-org/my-repo:*"
        }
      }
    }
  ]
}`}
                                    </pre>
                                </div>
                            </div>
                            <div className="flex justify-between mt-8">
                                <button onClick={() => setStep(1)} className="text-zinc-400 hover:text-white">Back</button>
                                <FederationButton onClick={() => setStep(3)} provider={selectedProvider || 'aws'}>
                                    Generate Policy
                                </FederationButton>
                            </div>
                        </motion.div>
                    )}

                    {step === 3 && (
                        <motion.div
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="flex flex-col items-center justify-center py-12 space-y-6"
                        >
                            <div className="w-20 h-20 rounded-full bg-emerald-500/20 flex items-center justify-center border border-emerald-500/50">
                                <Check className="w-10 h-10 text-emerald-400" />
                            </div>
                            <div className="text-center">
                                <h2 className="text-2xl font-cal text-white mb-2">Configuration Ready!</h2>
                                <p className="text-zinc-400 max-w-md">
                                    Your trust policy has been generated. Apply this to your {selectedProvider?.toUpperCase()} IAM role to enable keyless authentication.
                                </p>
                            </div>
                            <div className="flex gap-4">
                                <button onClick={() => setStep(1)} className="px-6 py-2 rounded-lg border border-white/10 text-white hover:bg-white/5 transition-colors">
                                    Configure Another
                                </button>
                                <FederationButton provider={selectedProvider || 'aws'} icon={ArrowRight}>
                                    View Integration Guide
                                </FederationButton>
                            </div>
                        </motion.div>
                    )}
                </div>
            </div>
        </KingdomShell>
    );
}
