# Changelog

## [0.3.0](https://github.com/willothy/micro-async.nvim/compare/v0.2.0...v0.3.0) (2023-12-01)


### Features

* add `block_on` function to synchronously wait for a task ([8c96db0](https://github.com/willothy/micro-async.nvim/commit/8c96db0579f889a38784a2ff5d05ac350f12d043))


### Bug Fixes

* ensure coroutine exists before resuming ([9b1fd48](https://github.com/willothy/micro-async.nvim/commit/9b1fd483898e46a29f6dc73e1c8952196dbe3e64))

## [0.2.0](https://github.com/willothy/micro-async.nvim/compare/v0.1.0...v0.2.0) (2023-10-18)


### Features

* add `join` to execute multiple tasks concurrently ([208da4b](https://github.com/willothy/micro-async.nvim/commit/208da4bc66fed1481afbe9bb2698dcc2492c9177))
* compat with versions using `vim.uv` or `vim.loop` ([1ba5748](https://github.com/willothy/micro-async.nvim/commit/1ba57481dbefe9a50ba0a330f412eb52be192064))
* propagate errors from tasks ([4faecc2](https://github.com/willothy/micro-async.nvim/commit/4faecc21df1881d70d033251dda848504c0b5bb6))


### Bug Fixes

* **ci:** wait for test setup to complete ([79c5d1f](https://github.com/willothy/micro-async.nvim/commit/79c5d1fe5e494a7aa9bbc54b0d00e553528a54c8))

## 0.1.0 (2023-10-17)


### Features

* add `scheduled_callback` ([230afda](https://github.com/willothy/micro-async.nvim/commit/230afda580248adcfb96709936f54c0e6de0c100))
* add `scheduled_wrap` function for luv API ([833e3b5](https://github.com/willothy/micro-async.nvim/commit/833e3b5a168c3414ae69de55c2a51898b2fc06d1))
* add `ui.select` and `ui.input` ([31746fe](https://github.com/willothy/micro-async.nvim/commit/31746fe49cd4ee8c2bf196b26e362339ae41b64d))
* add handles with cancellation support ([b0fb16c](https://github.com/willothy/micro-async.nvim/commit/b0fb16c1d2fec669e2f96af7027a996541bcf3c8))
* add lsp.request.code_actions ([4484191](https://github.com/willothy/micro-async.nvim/commit/4484191e35eae65bbb899229e2b2df729a0c23cd))
* allow cancellation for non-toplevel tasks ([d1b5d08](https://github.com/willothy/micro-async.nvim/commit/d1b5d089b5de16735babbbb758f026fae9e34af2))
* initial commit ([fb3cf50](https://github.com/willothy/micro-async.nvim/commit/fb3cf5041c11d9183b6c29c63de80ff1e148ea54))


### Bug Fixes

* `use scheduled_callback()` for `ui.input` ([1262ebc](https://github.com/willothy/micro-async.nvim/commit/1262ebc976679454642324ed236a26e0e6bd6287))
* **ci:** add quit_on_finish to test reporter ([d816451](https://github.com/willothy/micro-async.nvim/commit/d81645132ff1b8118c6b002f09e86479dfe915e4))
* doc generation for higher order functions using varargs ([0b93f65](https://github.com/willothy/micro-async.nvim/commit/0b93f655ec1eea277e3e8e11e64b090058080881))
* emmylua varargs ([aebcdaf](https://github.com/willothy/micro-async.nvim/commit/aebcdaf6bc3a3859452f3f2c1d09cbdfd2888eb9))


### Documentation

* add micro-async.txt ([b6480f2](https://github.com/willothy/micro-async.nvim/commit/b6480f2a404025ce3579dc80dafea7e0b5700df3))
