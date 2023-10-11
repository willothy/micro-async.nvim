---@mod micro-async.uv

local a = require("micro-async")

local yield, callback, wrap = a.yield, a.callback, a.wrap

---Async vim.uv wrapper
local uv = {}

---@type async fun(path: string, entries: integer): err: string?, dir: luv_dir_t
uv.fs_opendir = function(path, entries)
  ---@diagnostic disable-next-line: param-type-mismatch
  return yield(vim.uv.fs_opendir(path, callback(), entries))
end

---@type async fun(dir: luv_dir_t): err: string?, entries: uv.aliases.fs_readdir_entries[]
uv.fs_readdir = wrap(vim.uv.fs_readdir, 2)

---@type async fun(path: string): err: string?, path: string?
uv.fs_realpath = wrap(vim.uv.fs_realpath, 2)

---@type async fun(path: string): err: string?, path: string?
uv.fs_readlink = wrap(vim.uv.fs_readlink, 2)

---@type async fun(path: string, mode: integer): err: string?, permissions: boolean?
uv.fs_access = wrap(vim.uv.fs_access, 3)

---@type async fun(fd: integer, size: integer, offset: integer?): err: string?, data: string?
uv.fs_read = wrap(vim.uv.fs_read, 4)

---@type async fun(path: string, new_path: string): err: string?, success: boolean?
uv.fs_rename = wrap(vim.uv.fs_rename, 2)

---@type async fun(path: string, flags: integer | uv.aliases.fs_access_flags, mode: integer): err: string?, fs: integer?
uv.fs_open = wrap(vim.uv.fs_open, 4)

---@type async fun(template: string): err: string?, fd: integer?, path: string?
uv.fs_mkstemp = wrap(vim.uv.fs_mkstemp, 2)

---@type async fun(template: string): err: string?, path: string?
uv.fs_mkdtemp = wrap(vim.uv.fs_mkdtemp, 2)

---@type async fun(path: string): err: string?, success: boolean?
uv.fs_rmdir = wrap(vim.uv.fs_rmdir, 2)

---@type async fun(path: string, mode: integer): err: string?, success: boolean?
uv.fs_mkdir = wrap(vim.uv.fs_mkdir, 3)

---@type async fun(path: string, mode: integer): err: string?, success: boolean?
uv.fs_chmod = wrap(vim.uv.fs_chmod, 3)

---@type async fun(path: string, uid: integer, gid: integer): err: string?, success: boolean?
uv.fs_chown = wrap(vim.uv.fs_chown, 4)

---@type async fun(fd: integer, mode: integer): err: string?, success: boolean?
uv.fs_fchmod = wrap(vim.uv.fs_fchmod, 3)

---@type async fun(fd: integer, uid: integer, gid: integer): err: string?, success: boolean?
uv.fs_fchown = wrap(vim.uv.fs_fchown, 4)

---@type async fun(address: uv.aliases.getsockname_rtn)
uv.getnameinfo = wrap(vim.uv.getnameinfo, 2)

---@type async fun(path: string, new_path: string, flags: uv.aliases.fs_copyfile_flags): err: string?, success: boolean?
uv.fs_copyfile = wrap(vim.uv.fs_copyfile, 4)

---@type async fun(fd: integer, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_futime = wrap(vim.uv.fs_futime, 4)

---@type async fun(fd: integer, offset: integer): err: string?, success: boolean?
uv.fs_ftruncate = wrap(vim.uv.fs_ftruncate, 3)

---@type async fun(path: string, new_path: string): err: string?, success: boolean?
uv.fs_link = wrap(vim.uv.fs_link, 3)

---@type async fun(path: string): err: string?, success: boolean?
uv.fs_unlink = wrap(vim.uv.fs_unlink, 2)

---@type async fun(fd: integer, data: string | string[], offset: integer?): err: string?, success: boolean?
uv.fs_write = wrap(vim.uv.fs_write, 4)

---@type async fun(path: string, newpath: string, flags: integer | uv.aliases.fs_symlink_flags): err: string?, success: boolean?
uv.fs_symlink = wrap(vim.uv.fs_symlink, 3)

---@type async fun(path: string, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_lutime = wrap(vim.uv.fs_lutime, 4)

---@type async fun(path: string): err: string?, stat: uv.aliases.fs_stat_table
uv.fs_stat = wrap(vim.uv.fs_stat, 2)

---@type async fun(path: string): err: string?, stat: uv_fs_t?
uv.fs_scandir = wrap(vim.uv.fs_scandir, 2)

---@type async fun(path: string): err: string?, stat: uv.aliases.fs_statfs_stats
uv.fs_statfs = wrap(vim.uv.fs_statfs, 2)

---@type async fun(fd: integer): err: string?, success: boolean?
uv.fs_fsync = wrap(vim.uv.fs_fsync, 2)

---@type async fun(out_fd: integer, in_fd: integer, in_offset: integer, size: integer): err: string?, bytes: integer?
uv.fs_sendfile = wrap(vim.uv.fs_sendfile, 4)

---@type async fun(fd: integer): err: string?, success: boolean?
uv.fs_fdatasync = wrap(vim.uv.fs_fdatasync, 2)

---@type async fun(fd: integer): err: string?, success: boolean?
uv.fs_close = wrap(vim.uv.fs_close, 2)

---@type async fun(path: string, atime: integer, mtime: integer): err: string?, success: boolean?
uv.fs_utime = wrap(vim.uv.fs_utime, 4)

---@type async fun(fn: fun(...:uv.aliases.threadargs):...: uv.aliases.threadargs): luv_work_ctx_t
uv.new_work = function(fn)
  return vim.uv.new_work(fn, callback())
end

---@type async fun(work: luv_work_ctx_t, ...:uv.aliases.threadargs): ...: uv.aliases.threadargs
uv.queue_work = function(work, ...)
  return yield(vim.uv.queue_work(work, ...))
end

return uv
