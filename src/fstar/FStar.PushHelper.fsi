(* FStar.Interactive.Lsp and FStar.Interactive.Ide need to push various *
 * text fragments and update state; this file collects helpers for them *)
#light "off"

module FStar.PushHelper
open FStar.ST
open FStar.Util
open FStar.JsonHelper
open FStar.TypeChecker.Env

module DsEnv = FStar.Syntax.DsEnv
module CTable = FStar.Interactive.CompletionTable

type push_kind = | SyntaxCheck | LaxCheck | FullCheck
type ctx_depth_t = int * int * solver_depth_t * int
type deps_t = FStar.Parser.Dep.deps
type either_replst = either<repl_state, repl_state>

val repl_stack : ref<repl_stack_t>
val set_check_kind : env_t -> push_kind -> env_t

// Push an Pop, directly copied over from IDE
val push_repl : string -> push_kind -> repl_task -> repl_state -> repl_state
val pop_repl : string -> repl_state -> repl_state

// Factored out from IDE for use by LSP as well
val deps_and_repl_ld_tasks_of_our_file : string -> list<string> * list<repl_task> * deps_t

// Core functionality, directly copied over from IDE
val run_repl_task : optmod_t -> env_t -> repl_task -> optmod_t * env_t

// Factored out from IDE for use by LSP as well
val update_task_timestamps : repl_task -> repl_task
val add_module_completions : string -> list<string> -> CTable.table -> CTable.table

// Lax-check the whole file; used on didOpen
val full_lax : string -> repl_state -> repl_state