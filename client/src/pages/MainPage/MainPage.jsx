import React from 'react';
import { Home, Calendar, User } from 'lucide-react';
import { motion } from 'framer-motion';

export default function MainPage() {
    return (
        <div className="flex flex-col min-h-screen bg-gray-50">
            {/* Top Navbar */}
            <div className="flex justify-between items-center px-8 py-4 bg-white shadow">
                <h1 className="text-2xl font-bold">TalkPilot</h1>
                <div className="flex space-x-6">
                    <button className="px-4 py-2 bg-transparent text-gray-700 hover:text-blue-500">Script</button>
                    <button className="px-4 py-2 bg-transparent text-gray-700 hover:text-blue-500">Schedule</button>
                    <User className="w-6 h-6" />
                </div>
            </div>

            {/* Main Content */}
            <motion.div className="flex flex-col items-center justify-center flex-1 p-12" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                <h2 className="text-3xl font-semibold mb-6">Welcome to TalkPilot!</h2>
                <button className="px-6 py-3 mb-12 bg-blue-500 text-white rounded hover:bg-blue-600">Start a New Presentation</button>

                <div className="grid grid-cols-3 gap-8 w-full max-w-6xl">
                    <div className="flex flex-col items-center p-6 bg-white rounded shadow hover:shadow-lg transition">
                        <Home className="w-10 h-10 mb-3" />
                        <div className="text-lg font-medium">Script</div>
                    </div>
                    <div className="flex flex-col items-center p-6 bg-white rounded shadow hover:shadow-lg transition">
                        <Calendar className="w-10 h-10 mb-3" />
                        <div className="text-lg font-medium">Schedule</div>
                    </div>
                    <div className="flex flex-col items-center p-6 bg-white rounded shadow hover:shadow-lg transition">
                        <User className="w-10 h-10 mb-3" />
                        <div className="text-lg font-medium">Profile</div>
                    </div>
                </div>
            </motion.div>

            <footer className="px-8 py-4 bg-white text-center text-sm text-gray-500">© 2025 TalkPilot. All rights reserved.</footer>
        </div>
    );
}