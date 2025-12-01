'use client';

import React from 'react';
import { KingdomShell } from '@/components/layout/KingdomShell';
import { StatusBeacon } from '@/components/dashboard/StatusBeacon';
import { Shield, Search, Filter, Download, AlertTriangle, CheckCircle, Clock, Globe } from 'lucide-react';

export default function SecurityAudit() {
    const logs = [
        { id: 'evt_1', time: '2023-10-27 14:30:22', event: 'Token Exchange', principal: 'repo:acme/core:ref:refs/heads/main', provider: 'AWS', status: 'success', ip: '192.168.1.1' },
        { id: 'evt_2', time: '2023-10-27 14:28:15', event: 'Assume Role', principal: 'repo:acme/core:ref:refs/heads/dev', provider: 'GCP', status: 'success', ip: '192.168.1.2' },
        { id: 'evt_3', time: '2023-10-27 14:25:00', event: 'Policy Violation', principal: 'repo:acme/unknown:ref:refs/heads/main', provider: 'Azure', status: 'failure', ip: '10.0.0.5' },
        { id: 'evt_4', time: '2023-10-27 14:10:45', event: 'Token Exchange', principal: 'repo:acme/utils:ref:refs/heads/main', provider: 'AWS', status: 'success', ip: '192.168.1.3' },
        { id: 'evt_5', time: '2023-10-27 14:05:12', event: 'Token Rotation', principal: 'System', provider: 'Internal', status: 'success', ip: 'Local' },
    ];

    return (
        <KingdomShell>
            <div className="space-y-8">
                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-cal text-white mb-2">Security Audit</h1>
                        <p className="text-zinc-400">Inspect OIDC token exchanges and access patterns.</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-white transition-colors border border-white/10">
                            <Download className="w-4 h-4" />
                            <span>Export CSV</span>
                        </button>
                    </div>
                </div>

                {/* Filters */}
                <div className="flex items-center gap-4 p-4 bg-black/20 border border-white/10 rounded-xl backdrop-blur-sm">
                    <div className="relative flex-1">
                        <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-zinc-500" />
                        <input
                            type="text"
                            placeholder="Search by principal, event ID, or IP..."
                            className="w-full bg-white/5 border border-white/10 rounded-lg py-2 pl-10 pr-4 text-sm text-zinc-300 focus:outline-none focus:border-indigo-500/50"
                        />
                    </div>
                    <button className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white/5 hover:bg-white/10 text-zinc-300 transition-colors border border-white/10">
                        <Filter className="w-4 h-4" />
                        <span>Filter</span>
                    </button>
                </div>

                {/* Insights Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                    <div className="p-6 rounded-2xl bg-gradient-to-br from-indigo-900/20 to-purple-900/10 border border-indigo-500/20">
                        <div className="flex items-center gap-3 mb-4">
                            <div className="p-2 rounded-lg bg-indigo-500/20">
                                <Shield className="w-5 h-5 text-indigo-400" />
                            </div>
                            <h3 className="font-medium text-white">Security Score</h3>
                        </div>
                        <div className="flex items-end gap-2">
                            <span className="text-4xl font-mono text-white">98</span>
                            <span className="text-sm text-emerald-400 mb-1">/ 100</span>
                        </div>
                        <p className="text-xs text-zinc-500 mt-2">Based on policy strictness</p>
                    </div>

                    <div className="p-6 rounded-2xl bg-gradient-to-br from-emerald-900/20 to-teal-900/10 border border-emerald-500/20">
                        <div className="flex items-center gap-3 mb-4">
                            <div className="p-2 rounded-lg bg-emerald-500/20">
                                <CheckCircle className="w-5 h-5 text-emerald-400" />
                            </div>
                            <h3 className="font-medium text-white">Success Rate</h3>
                        </div>
                        <div className="flex items-end gap-2">
                            <span className="text-4xl font-mono text-white">99.9%</span>
                        </div>
                        <p className="text-xs text-zinc-500 mt-2">Last 24 hours</p>
                    </div>

                    <div className="p-6 rounded-2xl bg-gradient-to-br from-amber-900/20 to-orange-900/10 border border-amber-500/20">
                        <div className="flex items-center gap-3 mb-4">
                            <div className="p-2 rounded-lg bg-amber-500/20">
                                <AlertTriangle className="w-5 h-5 text-amber-400" />
                            </div>
                            <h3 className="font-medium text-white">Anomalies</h3>
                        </div>
                        <div className="flex items-end gap-2">
                            <span className="text-4xl font-mono text-white">1</span>
                        </div>
                        <p className="text-xs text-zinc-500 mt-2">Requires attention</p>
                    </div>
                </div>

                {/* Logs Table */}
                <div className="bg-black/20 border border-white/10 rounded-2xl overflow-hidden backdrop-blur-sm">
                    <table className="w-full text-left text-sm">
                        <thead className="bg-white/5 text-zinc-400 font-medium">
                            <tr>
                                <th className="px-6 py-4">Time</th>
                                <th className="px-6 py-4">Event</th>
                                <th className="px-6 py-4">Principal (Subject)</th>
                                <th className="px-6 py-4">Provider</th>
                                <th className="px-6 py-4">Status</th>
                                <th className="px-6 py-4">Source IP</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-white/5 text-zinc-300">
                            {logs.map((log) => (
                                <tr key={log.id} className="hover:bg-white/5 transition-colors group">
                                    <td className="px-6 py-4 font-mono text-xs text-zinc-500 group-hover:text-zinc-400">
                                        <div className="flex items-center gap-2">
                                            <Clock className="w-3 h-3" />
                                            {log.time}
                                        </div>
                                    </td>
                                    <td className="px-6 py-4 font-medium text-white">{log.event}</td>
                                    <td className="px-6 py-4 font-mono text-xs text-indigo-300">{log.principal}</td>
                                    <td className="px-6 py-4">{log.provider}</td>
                                    <td className="px-6 py-4">
                                        <StatusBeacon
                                            status={log.status === 'success' ? 'healthy' : 'critical'}
                                            label={log.status === 'success' ? 'Allowed' : 'Denied'}
                                            className="text-xs"
                                        />
                                    </td>
                                    <td className="px-6 py-4 text-zinc-500">
                                        <div className="flex items-center gap-2">
                                            <Globe className="w-3 h-3" />
                                            {log.ip}
                                        </div>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </div>
        </KingdomShell>
    );
}
