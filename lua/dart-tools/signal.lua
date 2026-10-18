-- Checks if a process has installed a handler for a signal.
-- `flutter run` only handles SIGUSR1/SIGUSR2 once the app is attached, before
-- that the default action of those signals is to kill the process.
local ffi = require("ffi")

local M = {}

local function catches_linux(pid, signum)
	local file = io.open("/proc/" .. pid .. "/status")
	if not file then
		return false
	end
	local status = file:read("*a")
	file:close()

	-- SigCgt is a hex mask of caught signals, the low 32 bits cover SIGUSR1/SIGUSR2
	local mask = status:match("SigCgt:%s*(%x+)")
	return mask ~= nil and bit.band(tonumber(mask:sub(-8), 16), bit.lshift(1, signum - 1)) ~= 0
end

-- Start of `struct extern_proc` from <sys/proc.h>, which is what sysctl(KERN_PROC_PID) returns
ffi.cdef([[
	struct dart_tools_timeval { long tv_sec; int32_t tv_usec; };
	struct dart_tools_extern_proc {
		union {
			struct { void *p_forw; void *p_back; } p_st1;
			struct dart_tools_timeval p_starttime;
		} p_un;
		void *p_vmspace;
		void *p_sigacts;
		int p_flag;
		char p_stat;
		int p_pid;
		int p_oppid;
		int p_dupfd;
		char *user_stack;
		void *exit_thread;
		int p_debugger;
		int sigwait;
		unsigned p_estcpu;
		int p_cpticks;
		uint32_t p_pctcpu;
		void *p_wchan;
		char *p_wmesg;
		unsigned p_swtime;
		unsigned p_slptime;
		struct dart_tools_timeval p_realtimer[2];
		struct dart_tools_timeval p_rtime;
		uint64_t p_uticks;
		uint64_t p_sticks;
		uint64_t p_iticks;
		int p_traceflag;
		void *p_tracep;
		int p_siglist;
		void *p_textvp;
		int p_holdcnt;
		uint32_t p_sigmask;
		uint32_t p_sigignore;
		uint32_t p_sigcatch;
	};
	int sysctl(int *name, unsigned namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen);
]])

local function catches_macos(pid, signum)
	local CTL_KERN, KERN_PROC, KERN_PROC_PID = 1, 14, 1
	local mib = ffi.new("int[4]", CTL_KERN, KERN_PROC, KERN_PROC_PID, pid)
	local buf = ffi.new("uint8_t[4096]")
	local len = ffi.new("size_t[1]", 4096)
	if ffi.C.sysctl(mib, 4, buf, len, nil, 0) ~= 0 or len[0] == 0 then
		return false
	end

	local proc = ffi.cast("struct dart_tools_extern_proc *", buf)
	-- guard against reading the wrong offsets
	if proc.p_pid ~= pid then
		return false
	end
	return bit.band(proc.p_sigcatch, bit.lshift(1, signum - 1)) ~= 0
end

---@param pid integer
---@param signum integer
---@return boolean
function M.catches(pid, signum)
	if vim.uv.os_uname().sysname == "Darwin" then
		return catches_macos(pid, signum)
	end
	return catches_linux(pid, signum)
end

return M
