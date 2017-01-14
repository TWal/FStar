
open Prims

let imp_tag : FStar_Absyn_Syntax.arg_qualifier = FStar_Absyn_Syntax.Implicit (false)


let as_imp : FStar_Parser_AST.imp  ->  FStar_Absyn_Syntax.arg_qualifier Prims.option = (fun uu___408 -> (match (uu___408) with
| (FStar_Parser_AST.Hash) | (FStar_Parser_AST.FsTypApp) -> begin
Some (imp_tag)
end
| _72_5 -> begin
None
end))


let arg_withimp_e = (fun imp t -> ((t), ((as_imp imp))))


let arg_withimp_t = (fun imp t -> (match (imp) with
| FStar_Parser_AST.Hash -> begin
((t), (Some (imp_tag)))
end
| _72_12 -> begin
((t), (None))
end))


let contains_binder : FStar_Parser_AST.binder Prims.list  ->  Prims.bool = (fun binders -> (FStar_All.pipe_right binders (FStar_Util.for_some (fun b -> (match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Annotated (_72_16) -> begin
true
end
| _72_19 -> begin
false
end)))))


let rec unparen : FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (t) -> begin
(unparen t)
end
| _72_24 -> begin
t
end))


let rec unlabel : FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (t) -> begin
(unlabel t)
end
| FStar_Parser_AST.Labeled (t, _72_30, _72_32) -> begin
(unlabel t)
end
| _72_36 -> begin
t
end))


let kind_star : FStar_Range.range  ->  FStar_Parser_AST.term = (fun r -> (let _173_17 = (let _173_16 = (FStar_Ident.lid_of_path (("Type")::[]) r)
in FStar_Parser_AST.Name (_173_16))
in (FStar_Parser_AST.mk_term _173_17 r FStar_Parser_AST.Kind)))


let compile_op : Prims.int  ->  Prims.string  ->  Prims.string = (fun arity s -> (

let name_of_char = (fun uu___409 -> (match (uu___409) with
| '&' -> begin
"Amp"
end
| '@' -> begin
"At"
end
| '+' -> begin
"Plus"
end
| '-' when (arity = (Prims.parse_int "1")) -> begin
"Minus"
end
| '-' -> begin
"Subtraction"
end
| '/' -> begin
"Slash"
end
| '<' -> begin
"Less"
end
| '=' -> begin
"Equals"
end
| '>' -> begin
"Greater"
end
| '_' -> begin
"Underscore"
end
| '|' -> begin
"Bar"
end
| '!' -> begin
"Bang"
end
| '^' -> begin
"Hat"
end
| '%' -> begin
"Percent"
end
| '*' -> begin
"Star"
end
| '?' -> begin
"Question"
end
| ':' -> begin
"Colon"
end
| _72_59 -> begin
"UNKNOWN"
end))
in (

let rec aux = (fun i -> if (i = (FStar_String.length s)) then begin
[]
end else begin
(let _173_28 = (let _173_26 = (FStar_Util.char_at s i)
in (name_of_char _173_26))
in (let _173_27 = (aux (i + (Prims.parse_int "1")))
in (_173_28)::_173_27))
end)
in (let _173_30 = (let _173_29 = (aux (Prims.parse_int "0"))
in (FStar_String.concat "_" _173_29))
in (Prims.strcat "op_" _173_30)))))


let compile_op_lid : Prims.int  ->  Prims.string  ->  FStar_Range.range  ->  FStar_Absyn_Syntax.lident = (fun n s r -> (let _173_40 = (let _173_39 = (let _173_38 = (let _173_37 = (compile_op n s)
in ((_173_37), (r)))
in (FStar_Absyn_Syntax.mk_ident _173_38))
in (_173_39)::[])
in (FStar_All.pipe_right _173_40 FStar_Absyn_Syntax.lid_of_ids)))


let op_as_vlid : FStar_Parser_DesugarEnv.env  ->  Prims.int  ->  FStar_Range.range  ->  Prims.string  ->  FStar_Ident.lident Prims.option = (fun env arity rng s -> (

let r = (fun l -> Some ((FStar_Ident.set_lid_range l rng)))
in (

let fallback = (fun _72_73 -> (match (()) with
| () -> begin
(match (s) with
| "=" -> begin
(r FStar_Absyn_Const.op_Eq)
end
| ":=" -> begin
(r FStar_Absyn_Const.write_lid)
end
| "<" -> begin
(r FStar_Absyn_Const.op_LT)
end
| "<=" -> begin
(r FStar_Absyn_Const.op_LTE)
end
| ">" -> begin
(r FStar_Absyn_Const.op_GT)
end
| ">=" -> begin
(r FStar_Absyn_Const.op_GTE)
end
| "&&" -> begin
(r FStar_Absyn_Const.op_And)
end
| "||" -> begin
(r FStar_Absyn_Const.op_Or)
end
| "*" -> begin
(r FStar_Absyn_Const.op_Multiply)
end
| "+" -> begin
(r FStar_Absyn_Const.op_Addition)
end
| "-" when (arity = (Prims.parse_int "1")) -> begin
(r FStar_Absyn_Const.op_Minus)
end
| "-" -> begin
(r FStar_Absyn_Const.op_Subtraction)
end
| "/" -> begin
(r FStar_Absyn_Const.op_Division)
end
| "%" -> begin
(r FStar_Absyn_Const.op_Modulus)
end
| "!" -> begin
(r FStar_Absyn_Const.read_lid)
end
| "@" -> begin
(r FStar_Absyn_Const.list_append_lid)
end
| "^" -> begin
(r FStar_Absyn_Const.strcat_lid)
end
| "|>" -> begin
(r FStar_Absyn_Const.pipe_right_lid)
end
| "<|" -> begin
(r FStar_Absyn_Const.pipe_left_lid)
end
| "<>" -> begin
(r FStar_Absyn_Const.op_notEq)
end
| _72_95 -> begin
None
end)
end))
in (match ((let _173_53 = (compile_op_lid arity s rng)
in (FStar_Parser_DesugarEnv.try_lookup_lid env _173_53))) with
| Some ({FStar_Absyn_Syntax.n = FStar_Absyn_Syntax.Exp_fvar (fv, _72_106); FStar_Absyn_Syntax.tk = _72_103; FStar_Absyn_Syntax.pos = _72_101; FStar_Absyn_Syntax.fvs = _72_99; FStar_Absyn_Syntax.uvs = _72_97}) -> begin
Some (fv.FStar_Absyn_Syntax.v)
end
| _72_112 -> begin
(fallback ())
end))))


let op_as_tylid : FStar_Parser_DesugarEnv.env  ->  Prims.int  ->  FStar_Range.range  ->  Prims.string  ->  FStar_Ident.lident Prims.option = (fun env arity rng s -> (

let r = (fun l -> Some ((FStar_Ident.set_lid_range l rng)))
in (match (s) with
| "~" -> begin
(r FStar_Absyn_Const.not_lid)
end
| "==" -> begin
(r FStar_Absyn_Const.eq2_lid)
end
| "=!=" -> begin
(r FStar_Absyn_Const.neq2_lid)
end
| "<<" -> begin
(r FStar_Absyn_Const.precedes_lid)
end
| "/\\" -> begin
(r FStar_Absyn_Const.and_lid)
end
| "\\/" -> begin
(r FStar_Absyn_Const.or_lid)
end
| "==>" -> begin
(r FStar_Absyn_Const.imp_lid)
end
| "<==>" -> begin
(r FStar_Absyn_Const.iff_lid)
end
| s -> begin
(match ((let _173_64 = (compile_op_lid arity s rng)
in (FStar_Parser_DesugarEnv.try_lookup_typ_name env _173_64))) with
| Some ({FStar_Absyn_Syntax.n = FStar_Absyn_Syntax.Typ_const (ftv); FStar_Absyn_Syntax.tk = _72_135; FStar_Absyn_Syntax.pos = _72_133; FStar_Absyn_Syntax.fvs = _72_131; FStar_Absyn_Syntax.uvs = _72_129}) -> begin
Some (ftv.FStar_Absyn_Syntax.v)
end
| _72_141 -> begin
None
end)
end)))


let rec is_type : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  Prims.bool = (fun env t -> if (t.FStar_Parser_AST.level = FStar_Parser_AST.Type_level) then begin
true
end else begin
(match ((let _173_71 = (unparen t)
in _173_71.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Wild -> begin
true
end
| FStar_Parser_AST.Labeled (_72_146) -> begin
true
end
| FStar_Parser_AST.Op ("*", (hd)::_72_150) -> begin
(is_type env hd)
end
| (FStar_Parser_AST.Op ("==", _)) | (FStar_Parser_AST.Op ("=!=", _)) | (FStar_Parser_AST.Op ("~", _)) | (FStar_Parser_AST.Op ("/\\", _)) | (FStar_Parser_AST.Op ("\\/", _)) | (FStar_Parser_AST.Op ("==>", _)) | (FStar_Parser_AST.Op ("<==>", _)) | (FStar_Parser_AST.Op ("<<", _)) -> begin
true
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((op_as_tylid env (FStar_List.length args) t.FStar_Parser_AST.range s)) with
| None -> begin
false
end
| _72_201 -> begin
true
end)
end
| (FStar_Parser_AST.QForall (_)) | (FStar_Parser_AST.QExists (_)) | (FStar_Parser_AST.Sum (_)) | (FStar_Parser_AST.Refine (_)) | (FStar_Parser_AST.Tvar (_)) | (FStar_Parser_AST.NamedTyp (_)) -> begin
true
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) when ((FStar_List.length l.FStar_Ident.ns) = (Prims.parse_int "0")) -> begin
(match ((FStar_Parser_DesugarEnv.try_lookup_typ_var env l.FStar_Ident.ident)) with
| Some (_72_224) -> begin
true
end
| _72_227 -> begin
(FStar_Parser_DesugarEnv.is_type_lid env l)
end)
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) | (FStar_Parser_AST.Construct (l, _)) -> begin
(FStar_Parser_DesugarEnv.is_type_lid env l)
end
| (FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (l); FStar_Parser_AST.range = _; FStar_Parser_AST.level = _}, arg, FStar_Parser_AST.Nothing)) | (FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = _; FStar_Parser_AST.level = _}, arg, FStar_Parser_AST.Nothing)) when (l.FStar_Ident.str = "ref") -> begin
(is_type env arg)
end
| (FStar_Parser_AST.App (t, _, _)) | (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) -> begin
(is_type env t)
end
| FStar_Parser_AST.Product (_72_268, t) -> begin
(not ((is_kind env t)))
end
| FStar_Parser_AST.If (t, t1, t2) -> begin
(((is_type env t) || (is_type env t1)) || (is_type env t2))
end
| FStar_Parser_AST.Abs (pats, t) -> begin
(

let rec aux = (fun env pats -> (match (pats) with
| [] -> begin
(is_type env t)
end
| (hd)::pats -> begin
(match (hd.FStar_Parser_AST.pat) with
| (FStar_Parser_AST.PatWild) | (FStar_Parser_AST.PatVar (_)) -> begin
(aux env pats)
end
| FStar_Parser_AST.PatTvar (id, _72_294) -> begin
(

let _72_300 = (FStar_Parser_DesugarEnv.push_local_tbinding env id)
in (match (_72_300) with
| (env, _72_299) -> begin
(aux env pats)
end))
end
| FStar_Parser_AST.PatAscribed (p, tm) -> begin
(

let env = if (is_kind env tm) then begin
(match (p.FStar_Parser_AST.pat) with
| (FStar_Parser_AST.PatVar (id, _)) | (FStar_Parser_AST.PatTvar (id, _)) -> begin
(let _173_76 = (FStar_Parser_DesugarEnv.push_local_tbinding env id)
in (FStar_All.pipe_right _173_76 Prims.fst))
end
| _72_315 -> begin
env
end)
end else begin
env
end
in (aux env pats))
end
| _72_318 -> begin
false
end)
end))
in (aux env pats))
end
| FStar_Parser_AST.Let (FStar_Parser_AST.NoLetQualifier, (({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_72_323); FStar_Parser_AST.prange = _72_321}, _72_327))::[], t) -> begin
(is_type env t)
end
| FStar_Parser_AST.Let (FStar_Parser_AST.NoLetQualifier, (({FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_72_339); FStar_Parser_AST.prange = _72_337}, _72_343); FStar_Parser_AST.prange = _72_335}, _72_348))::[], t) -> begin
(is_type env t)
end
| FStar_Parser_AST.Let (FStar_Parser_AST.NoLetQualifier, (({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_72_358); FStar_Parser_AST.prange = _72_356}, _72_362))::[], t) -> begin
(is_type env t)
end
| _72_369 -> begin
false
end)
end)
and is_kind : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  Prims.bool = (fun env t -> if (t.FStar_Parser_AST.level = FStar_Parser_AST.Kind) then begin
true
end else begin
(match ((let _173_79 = (unparen t)
in _173_79.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Name ({FStar_Ident.ns = _72_378; FStar_Ident.ident = _72_376; FStar_Ident.nsstr = _72_374; FStar_Ident.str = "Type"}) -> begin
true
end
| FStar_Parser_AST.Product (_72_382, t) -> begin
(is_kind env t)
end
| FStar_Parser_AST.Paren (t) -> begin
(is_kind env t)
end
| (FStar_Parser_AST.Construct (l, _)) | (FStar_Parser_AST.Name (l)) -> begin
(FStar_Parser_DesugarEnv.is_kind_abbrev env l)
end
| _72_395 -> begin
false
end)
end)


let rec is_type_binder : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder  ->  Prims.bool = (fun env b -> if (b.FStar_Parser_AST.blevel = FStar_Parser_AST.Formula) then begin
(match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (_72_399) -> begin
false
end
| (FStar_Parser_AST.TAnnotated (_)) | (FStar_Parser_AST.TVariable (_)) -> begin
true
end
| (FStar_Parser_AST.Annotated (_, t)) | (FStar_Parser_AST.NoName (t)) -> begin
(is_kind env t)
end)
end else begin
(match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (_72_414) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected binder without annotation"), (b.FStar_Parser_AST.brange)))))
end
| FStar_Parser_AST.TVariable (_72_417) -> begin
false
end
| FStar_Parser_AST.TAnnotated (_72_420) -> begin
true
end
| (FStar_Parser_AST.Annotated (_, t)) | (FStar_Parser_AST.NoName (t)) -> begin
(is_kind env t)
end)
end)


let sort_ftv : FStar_Ident.ident Prims.list  ->  FStar_Ident.ident Prims.list = (fun ftv -> (let _173_90 = (FStar_Util.remove_dups (fun x y -> (x.FStar_Ident.idText = y.FStar_Ident.idText)) ftv)
in (FStar_All.pipe_left (FStar_Util.sort_with (fun x y -> (FStar_String.compare x.FStar_Ident.idText y.FStar_Ident.idText))) _173_90)))


let rec free_type_vars_b : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder  ->  (FStar_Parser_DesugarEnv.env * FStar_Ident.ident Prims.list) = (fun env binder -> (match (binder.FStar_Parser_AST.b) with
| FStar_Parser_AST.Variable (_72_436) -> begin
((env), ([]))
end
| FStar_Parser_AST.TVariable (x) -> begin
(

let _72_443 = (FStar_Parser_DesugarEnv.push_local_tbinding env x)
in (match (_72_443) with
| (env, _72_442) -> begin
((env), ((x)::[]))
end))
end
| FStar_Parser_AST.Annotated (_72_445, term) -> begin
(let _173_97 = (free_type_vars env term)
in ((env), (_173_97)))
end
| FStar_Parser_AST.TAnnotated (id, _72_451) -> begin
(

let _72_457 = (FStar_Parser_DesugarEnv.push_local_tbinding env id)
in (match (_72_457) with
| (env, _72_456) -> begin
((env), ([]))
end))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _173_98 = (free_type_vars env t)
in ((env), (_173_98)))
end))
and free_type_vars : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Ident.ident Prims.list = (fun env t -> (match ((let _173_101 = (unparen t)
in _173_101.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Tvar (a) -> begin
(match ((FStar_Parser_DesugarEnv.try_lookup_typ_var env a)) with
| None -> begin
(a)::[]
end
| _72_466 -> begin
[]
end)
end
| (FStar_Parser_AST.Wild) | (FStar_Parser_AST.Const (_)) | (FStar_Parser_AST.Uvar (_)) | (FStar_Parser_AST.Var (_)) | (FStar_Parser_AST.Projector (_)) | (FStar_Parser_AST.Discrim (_)) | (FStar_Parser_AST.Name (_)) -> begin
[]
end
| (FStar_Parser_AST.Requires (t, _)) | (FStar_Parser_AST.Ensures (t, _)) | (FStar_Parser_AST.Labeled (t, _, _)) | (FStar_Parser_AST.NamedTyp (_, t)) | (FStar_Parser_AST.Paren (t)) | (FStar_Parser_AST.Ascribed (t, _)) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Construct (_72_511, ts) -> begin
(FStar_List.collect (fun _72_518 -> (match (_72_518) with
| (t, _72_517) -> begin
(free_type_vars env t)
end)) ts)
end
| FStar_Parser_AST.Op (_72_520, ts) -> begin
(FStar_List.collect (free_type_vars env) ts)
end
| FStar_Parser_AST.App (t1, t2, _72_527) -> begin
(let _173_104 = (free_type_vars env t1)
in (let _173_103 = (free_type_vars env t2)
in (FStar_List.append _173_104 _173_103)))
end
| FStar_Parser_AST.Refine (b, t) -> begin
(

let _72_536 = (free_type_vars_b env b)
in (match (_72_536) with
| (env, f) -> begin
(let _173_105 = (free_type_vars env t)
in (FStar_List.append f _173_105))
end))
end
| (FStar_Parser_AST.Product (binders, body)) | (FStar_Parser_AST.Sum (binders, body)) -> begin
(

let _72_552 = (FStar_List.fold_left (fun _72_545 binder -> (match (_72_545) with
| (env, free) -> begin
(

let _72_549 = (free_type_vars_b env binder)
in (match (_72_549) with
| (env, f) -> begin
((env), ((FStar_List.append f free)))
end))
end)) ((env), ([])) binders)
in (match (_72_552) with
| (env, free) -> begin
(let _173_108 = (free_type_vars env body)
in (FStar_List.append free _173_108))
end))
end
| FStar_Parser_AST.Project (t, _72_555) -> begin
(free_type_vars env t)
end
| FStar_Parser_AST.Attributes (cattributes) -> begin
(FStar_List.collect (free_type_vars env) cattributes)
end
| (FStar_Parser_AST.Abs (_)) | (FStar_Parser_AST.Let (_)) | (FStar_Parser_AST.LetOpen (_)) | (FStar_Parser_AST.If (_)) | (FStar_Parser_AST.QForall (_)) | (FStar_Parser_AST.QExists (_)) -> begin
[]
end
| (FStar_Parser_AST.Record (_)) | (FStar_Parser_AST.Match (_)) | (FStar_Parser_AST.TryWith (_)) | (FStar_Parser_AST.Assign (_)) | (FStar_Parser_AST.Seq (_)) -> begin
(FStar_Parser_AST.error "Unexpected type in free_type_vars computation" t t.FStar_Parser_AST.range)
end))


let head_and_args : FStar_Parser_AST.term  ->  (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list) = (fun t -> (

let rec aux = (fun args t -> (match ((let _173_115 = (unparen t)
in _173_115.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (t, arg, imp) -> begin
(aux ((((arg), (imp)))::args) t)
end
| FStar_Parser_AST.Construct (l, args') -> begin
(({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = t.FStar_Parser_AST.range; FStar_Parser_AST.level = t.FStar_Parser_AST.level}), ((FStar_List.append args' args)))
end
| _72_607 -> begin
((t), (args))
end))
in (aux [] t)))


let close : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _173_120 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _173_120))
in if ((FStar_List.length ftv) = (Prims.parse_int "0")) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _173_124 = (let _173_123 = (let _173_122 = (kind_star x.FStar_Ident.idRange)
in ((x), (_173_122)))
in FStar_Parser_AST.TAnnotated (_173_123))
in (FStar_Parser_AST.mk_binder _173_124 x.FStar_Ident.idRange FStar_Parser_AST.Type_level (Some (FStar_Parser_AST.Implicit)))))))
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result))
end))


let close_fun : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun env t -> (

let ftv = (let _173_129 = (free_type_vars env t)
in (FStar_All.pipe_left sort_ftv _173_129))
in if ((FStar_List.length ftv) = (Prims.parse_int "0")) then begin
t
end else begin
(

let binders = (FStar_All.pipe_right ftv (FStar_List.map (fun x -> (let _173_133 = (let _173_132 = (let _173_131 = (kind_star x.FStar_Ident.idRange)
in ((x), (_173_131)))
in FStar_Parser_AST.TAnnotated (_173_132))
in (FStar_Parser_AST.mk_binder _173_133 x.FStar_Ident.idRange FStar_Parser_AST.Type_level (Some (FStar_Parser_AST.Implicit)))))))
in (

let t = (match ((let _173_134 = (unlabel t)
in _173_134.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Product (_72_620) -> begin
t
end
| _72_623 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.effect_Tot_lid)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end)
in (

let result = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((binders), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in result)))
end))


let rec uncurry : FStar_Parser_AST.binder Prims.list  ->  FStar_Parser_AST.term  ->  (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term) = (fun bs t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Product (binders, t) -> begin
(uncurry (FStar_List.append bs binders) t)
end
| _72_633 -> begin
((bs), (t))
end))


let rec is_app_pattern : FStar_Parser_AST.pattern  ->  Prims.bool = (fun p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, _72_637) -> begin
(is_app_pattern p)
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (_72_643); FStar_Parser_AST.prange = _72_641}, _72_647) -> begin
true
end
| _72_651 -> begin
false
end))


let rec destruct_app_pattern : FStar_Parser_DesugarEnv.env  ->  Prims.bool  ->  FStar_Parser_AST.pattern  ->  ((FStar_Ident.ident, FStar_Ident.lident) FStar_Util.either * FStar_Parser_AST.pattern Prims.list * FStar_Parser_AST.term Prims.option) = (fun env is_top_level p -> (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let _72_663 = (destruct_app_pattern env is_top_level p)
in (match (_72_663) with
| (name, args, _72_662) -> begin
((name), (args), (Some (t)))
end))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _72_668); FStar_Parser_AST.prange = _72_665}, args) when is_top_level -> begin
(let _173_148 = (let _173_147 = (FStar_Parser_DesugarEnv.qualify env id)
in FStar_Util.Inr (_173_147))
in ((_173_148), (args), (None)))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _72_679); FStar_Parser_AST.prange = _72_676}, args) -> begin
((FStar_Util.Inl (id)), (args), (None))
end
| _72_687 -> begin
(failwith "Not an app pattern")
end))


type bnd =
| TBinder of (FStar_Absyn_Syntax.btvdef * FStar_Absyn_Syntax.knd * FStar_Absyn_Syntax.aqual)
| VBinder of (FStar_Absyn_Syntax.bvvdef * FStar_Absyn_Syntax.typ * FStar_Absyn_Syntax.aqual)
| LetBinder of (FStar_Ident.lident * FStar_Absyn_Syntax.typ)


let is_TBinder = (fun _discr_ -> (match (_discr_) with
| TBinder (_) -> begin
true
end
| _ -> begin
false
end))


let is_VBinder = (fun _discr_ -> (match (_discr_) with
| VBinder (_) -> begin
true
end
| _ -> begin
false
end))


let is_LetBinder = (fun _discr_ -> (match (_discr_) with
| LetBinder (_) -> begin
true
end
| _ -> begin
false
end))


let ___TBinder____0 = (fun projectee -> (match (projectee) with
| TBinder (_72_690) -> begin
_72_690
end))


let ___VBinder____0 = (fun projectee -> (match (projectee) with
| VBinder (_72_693) -> begin
_72_693
end))


let ___LetBinder____0 = (fun projectee -> (match (projectee) with
| LetBinder (_72_696) -> begin
_72_696
end))


let binder_of_bnd : bnd  ->  ((((FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, FStar_Absyn_Syntax.knd) FStar_Absyn_Syntax.withinfo_t, ((FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, FStar_Absyn_Syntax.typ) FStar_Absyn_Syntax.withinfo_t) FStar_Util.either * FStar_Absyn_Syntax.aqual) = (fun uu___410 -> (match (uu___410) with
| TBinder (a, k, aq) -> begin
((FStar_Util.Inl ((FStar_Absyn_Util.bvd_to_bvar_s a k))), (aq))
end
| VBinder (x, t, aq) -> begin
((FStar_Util.Inr ((FStar_Absyn_Util.bvd_to_bvar_s x t))), (aq))
end
| _72_709 -> begin
(failwith "Impossible")
end))


let trans_aqual : FStar_Parser_AST.arg_qualifier Prims.option  ->  FStar_Absyn_Syntax.arg_qualifier Prims.option = (fun uu___411 -> (match (uu___411) with
| Some (FStar_Parser_AST.Implicit) -> begin
Some (imp_tag)
end
| Some (FStar_Parser_AST.Equality) -> begin
Some (FStar_Absyn_Syntax.Equality)
end
| _72_716 -> begin
None
end))


let as_binder : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.arg_qualifier Prims.option  ->  ((FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.knd), (FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.typ)) FStar_Util.either  ->  (FStar_Absyn_Syntax.binder * FStar_Parser_DesugarEnv.env) = (fun env imp uu___412 -> (match (uu___412) with
| FStar_Util.Inl (None, k) -> begin
(let _173_201 = (FStar_Absyn_Syntax.null_t_binder k)
in ((_173_201), (env)))
end
| FStar_Util.Inr (None, t) -> begin
(let _173_202 = (FStar_Absyn_Syntax.null_v_binder t)
in ((_173_202), (env)))
end
| FStar_Util.Inl (Some (a), k) -> begin
(

let _72_735 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (match (_72_735) with
| (env, a) -> begin
((((FStar_Util.Inl ((FStar_Absyn_Util.bvd_to_bvar_s a k))), ((trans_aqual imp)))), (env))
end))
end
| FStar_Util.Inr (Some (x), t) -> begin
(

let _72_743 = (FStar_Parser_DesugarEnv.push_local_vbinding env x)
in (match (_72_743) with
| (env, x) -> begin
((((FStar_Util.Inr ((FStar_Absyn_Util.bvd_to_bvar_s x t))), ((trans_aqual imp)))), (env))
end))
end))


type env_t =
FStar_Parser_DesugarEnv.env


type lenv_t =
(FStar_Absyn_Syntax.btvdef, FStar_Absyn_Syntax.bvvdef) FStar_Util.either Prims.list


let label_conjuncts : Prims.string  ->  Prims.bool  ->  Prims.string Prims.option  ->  FStar_Parser_AST.term  ->  FStar_Parser_AST.term = (fun tag polarity label_opt f -> (

let label = (fun f -> (

let msg = (match (label_opt) with
| Some (l) -> begin
l
end
| _72_753 -> begin
(let _173_213 = (FStar_Range.string_of_range f.FStar_Parser_AST.range)
in (FStar_Util.format2 "%s at %s" tag _173_213))
end)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.Labeled (((f), (msg), (polarity)))) f.FStar_Parser_AST.range f.FStar_Parser_AST.level)))
in (

let rec aux = (fun f -> (match (f.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Paren (g) -> begin
(let _173_217 = (let _173_216 = (aux g)
in FStar_Parser_AST.Paren (_173_216))
in (FStar_Parser_AST.mk_term _173_217 f.FStar_Parser_AST.range f.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Op ("/\\", (f1)::(f2)::[]) -> begin
(let _173_223 = (let _173_222 = (let _173_221 = (let _173_220 = (aux f1)
in (let _173_219 = (let _173_218 = (aux f2)
in (_173_218)::[])
in (_173_220)::_173_219))
in (("/\\"), (_173_221)))
in FStar_Parser_AST.Op (_173_222))
in (FStar_Parser_AST.mk_term _173_223 f.FStar_Parser_AST.range f.FStar_Parser_AST.level))
end
| FStar_Parser_AST.If (f1, f2, f3) -> begin
(let _173_227 = (let _173_226 = (let _173_225 = (aux f2)
in (let _173_224 = (aux f3)
in ((f1), (_173_225), (_173_224))))
in FStar_Parser_AST.If (_173_226))
in (FStar_Parser_AST.mk_term _173_227 f.FStar_Parser_AST.range f.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Abs (binders, g) -> begin
(let _173_230 = (let _173_229 = (let _173_228 = (aux g)
in ((binders), (_173_228)))
in FStar_Parser_AST.Abs (_173_229))
in (FStar_Parser_AST.mk_term _173_230 f.FStar_Parser_AST.range f.FStar_Parser_AST.level))
end
| _72_775 -> begin
(label f)
end))
in (aux f))))


let mk_lb : (FStar_Absyn_Syntax.lbname * FStar_Absyn_Syntax.typ * FStar_Absyn_Syntax.exp)  ->  FStar_Absyn_Syntax.letbinding = (fun _72_779 -> (match (_72_779) with
| (n, t, e) -> begin
{FStar_Absyn_Syntax.lbname = n; FStar_Absyn_Syntax.lbtyp = t; FStar_Absyn_Syntax.lbeff = FStar_Absyn_Const.effect_ALL_lid; FStar_Absyn_Syntax.lbdef = e}
end))


let rec desugar_data_pat : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Absyn_Syntax.pat) = (fun env p -> (

let resolvex = (fun l e x -> (match ((FStar_All.pipe_right l (FStar_Util.find_opt (fun uu___413 -> (match (uu___413) with
| FStar_Util.Inr (y) -> begin
(y.FStar_Absyn_Syntax.ppname.FStar_Ident.idText = x.FStar_Ident.idText)
end
| _72_790 -> begin
false
end))))) with
| Some (FStar_Util.Inr (y)) -> begin
((l), (e), (y))
end
| _72_795 -> begin
(

let _72_798 = (FStar_Parser_DesugarEnv.push_local_vbinding e x)
in (match (_72_798) with
| (e, x) -> begin
(((FStar_Util.Inr (x))::l), (e), (x))
end))
end))
in (

let resolvea = (fun l e a -> (match ((FStar_All.pipe_right l (FStar_Util.find_opt (fun uu___414 -> (match (uu___414) with
| FStar_Util.Inl (b) -> begin
(b.FStar_Absyn_Syntax.ppname.FStar_Ident.idText = a.FStar_Ident.idText)
end
| _72_807 -> begin
false
end))))) with
| Some (FStar_Util.Inl (b)) -> begin
((l), (e), (b))
end
| _72_812 -> begin
(

let _72_815 = (FStar_Parser_DesugarEnv.push_local_tbinding e a)
in (match (_72_815) with
| (e, a) -> begin
(((FStar_Util.Inl (a))::l), (e), (a))
end))
end))
in (

let rec aux = (fun loc env p -> (

let pos = (fun q -> (FStar_Absyn_Syntax.withinfo q None p.FStar_Parser_AST.prange))
in (

let pos_r = (fun r q -> (FStar_Absyn_Syntax.withinfo q None r))
in (match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatOp (_72_826) -> begin
(failwith "let op not supported in stratified")
end
| FStar_Parser_AST.PatOr ([]) -> begin
(failwith "impossible")
end
| FStar_Parser_AST.PatOr ((p)::ps) -> begin
(

let _72_840 = (aux loc env p)
in (match (_72_840) with
| (loc, env, var, p, _72_839) -> begin
(

let _72_857 = (FStar_List.fold_left (fun _72_844 p -> (match (_72_844) with
| (loc, env, ps) -> begin
(

let _72_853 = (aux loc env p)
in (match (_72_853) with
| (loc, env, _72_849, p, _72_852) -> begin
((loc), (env), ((p)::ps))
end))
end)) ((loc), (env), ([])) ps)
in (match (_72_857) with
| (loc, env, ps) -> begin
(

let pat = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_disj ((p)::(FStar_List.rev ps))))
in (

let _72_859 = (let _173_307 = (FStar_Absyn_Syntax.pat_vars pat)
in (Prims.ignore _173_307))
in ((loc), (env), (var), (pat), (false))))
end))
end))
end
| FStar_Parser_AST.PatAscribed (p, t) -> begin
(

let p = if (is_kind env t) then begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatTvar (_72_866) -> begin
p
end
| FStar_Parser_AST.PatVar (x, imp) -> begin
(

let _72_872 = p
in {FStar_Parser_AST.pat = FStar_Parser_AST.PatTvar (((x), (imp))); FStar_Parser_AST.prange = _72_872.FStar_Parser_AST.prange})
end
| _72_875 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end)
end else begin
p
end
in (

let _72_882 = (aux loc env p)
in (match (_72_882) with
| (loc, env', binder, p, imp) -> begin
(

let binder = (match (binder) with
| LetBinder (_72_884) -> begin
(failwith "impossible")
end
| TBinder (x, _72_888, aq) -> begin
(let _173_309 = (let _173_308 = (desugar_kind env t)
in ((x), (_173_308), (aq)))
in TBinder (_173_309))
end
| VBinder (x, _72_894, aq) -> begin
(

let t = (close_fun env t)
in (let _173_311 = (let _173_310 = (desugar_typ env t)
in ((x), (_173_310), (aq)))
in VBinder (_173_311)))
end)
in ((loc), (env'), (binder), (p), (imp)))
end)))
end
| FStar_Parser_AST.PatTvar (a, aq) -> begin
(

let imp = (aq = Some (FStar_Parser_AST.Implicit))
in (

let aq = (trans_aqual aq)
in if (a.FStar_Ident.idText = "\'_") then begin
(

let a = (FStar_All.pipe_left FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_312 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_twild ((FStar_Absyn_Util.bvd_to_bvar_s a FStar_Absyn_Syntax.kun))))
in ((loc), (env), (TBinder (((a), (FStar_Absyn_Syntax.kun), (aq)))), (_173_312), (imp))))
end else begin
(

let _72_910 = (resolvea loc env a)
in (match (_72_910) with
| (loc, env, abvd) -> begin
(let _173_313 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_tvar ((FStar_Absyn_Util.bvd_to_bvar_s abvd FStar_Absyn_Syntax.kun))))
in ((loc), (env), (TBinder (((abvd), (FStar_Absyn_Syntax.kun), (aq)))), (_173_313), (imp)))
end))
end))
end
| FStar_Parser_AST.PatWild -> begin
(

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (

let y = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_314 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_wild ((FStar_Absyn_Util.bvd_to_bvar_s y FStar_Absyn_Syntax.tun))))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (_173_314), (false)))))
end
| FStar_Parser_AST.PatConst (c) -> begin
(

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_315 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_constant (c)))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (_173_315), (false))))
end
| FStar_Parser_AST.PatVar (x, aq) -> begin
(

let imp = (aq = Some (FStar_Parser_AST.Implicit))
in (

let aq = (trans_aqual aq)
in (

let _72_926 = (resolvex loc env x)
in (match (_72_926) with
| (loc, env, xbvd) -> begin
(let _173_316 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_var ((FStar_Absyn_Util.bvd_to_bvar_s xbvd FStar_Absyn_Syntax.tun))))
in ((loc), (env), (VBinder (((xbvd), (FStar_Absyn_Syntax.tun), (aq)))), (_173_316), (imp)))
end))))
end
| FStar_Parser_AST.PatName (l) -> begin
(

let l = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_datacon env) l)
in (

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_317 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_cons (((l), (Some (FStar_Absyn_Syntax.Data_ctor)), ([])))))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (_173_317), (false)))))
end
| FStar_Parser_AST.PatApp ({FStar_Parser_AST.pat = FStar_Parser_AST.PatName (l); FStar_Parser_AST.prange = _72_932}, args) -> begin
(

let _72_954 = (FStar_List.fold_right (fun arg _72_943 -> (match (_72_943) with
| (loc, env, args) -> begin
(

let _72_950 = (aux loc env arg)
in (match (_72_950) with
| (loc, env, _72_947, arg, imp) -> begin
((loc), (env), ((((arg), (imp)))::args))
end))
end)) args ((loc), (env), ([])))
in (match (_72_954) with
| (loc, env, args) -> begin
(

let l = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_datacon env) l)
in (

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_320 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_cons (((l), (Some (FStar_Absyn_Syntax.Data_ctor)), (args)))))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (_173_320), (false)))))
end))
end
| FStar_Parser_AST.PatApp (_72_958) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatList (pats) -> begin
(

let _72_978 = (FStar_List.fold_right (fun pat _72_966 -> (match (_72_966) with
| (loc, env, pats) -> begin
(

let _72_974 = (aux loc env pat)
in (match (_72_974) with
| (loc, env, _72_970, pat, _72_973) -> begin
((loc), (env), ((pat)::pats))
end))
end)) pats ((loc), (env), ([])))
in (match (_72_978) with
| (loc, env, pats) -> begin
(

let pat = (let _173_327 = (let _173_326 = (let _173_325 = (FStar_Range.end_range p.FStar_Parser_AST.prange)
in (pos_r _173_325))
in (FStar_All.pipe_left _173_326 (FStar_Absyn_Syntax.Pat_cons ((((FStar_Absyn_Util.fv FStar_Absyn_Const.nil_lid)), (Some (FStar_Absyn_Syntax.Data_ctor)), ([]))))))
in (FStar_List.fold_right (fun hd tl -> (

let r = (FStar_Range.union_ranges hd.FStar_Absyn_Syntax.p tl.FStar_Absyn_Syntax.p)
in (FStar_All.pipe_left (pos_r r) (FStar_Absyn_Syntax.Pat_cons ((((FStar_Absyn_Util.fv FStar_Absyn_Const.cons_lid)), (Some (FStar_Absyn_Syntax.Data_ctor)), ((((hd), (false)))::(((tl), (false)))::[]))))))) pats _173_327))
in (

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (pat), (false))))
end))
end
| FStar_Parser_AST.PatTuple (args, dep) -> begin
(

let _72_1004 = (FStar_List.fold_left (fun _72_991 p -> (match (_72_991) with
| (loc, env, pats) -> begin
(

let _72_1000 = (aux loc env p)
in (match (_72_1000) with
| (loc, env, _72_996, pat, _72_999) -> begin
((loc), (env), ((((pat), (false)))::pats))
end))
end)) ((loc), (env), ([])) args)
in (match (_72_1004) with
| (loc, env, args) -> begin
(

let args = (FStar_List.rev args)
in (

let l = if dep then begin
(FStar_Absyn_Util.mk_dtuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end else begin
(FStar_Absyn_Util.mk_tuple_data_lid (FStar_List.length args) p.FStar_Parser_AST.prange)
end
in (

let constr = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_lid env) l)
in (

let l = (match (constr.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Exp_fvar (v, _72_1010) -> begin
v
end
| _72_1014 -> begin
(failwith "impossible")
end)
in (

let x = (FStar_Absyn_Util.new_bvd (Some (p.FStar_Parser_AST.prange)))
in (let _173_330 = (FStar_All.pipe_left pos (FStar_Absyn_Syntax.Pat_cons (((l), (Some (FStar_Absyn_Syntax.Data_ctor)), (args)))))
in ((loc), (env), (VBinder (((x), (FStar_Absyn_Syntax.tun), (None)))), (_173_330), (false))))))))
end))
end
| FStar_Parser_AST.PatRecord ([]) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern"), (p.FStar_Parser_AST.prange)))))
end
| FStar_Parser_AST.PatRecord (fields) -> begin
(

let _72_1024 = (FStar_List.hd fields)
in (match (_72_1024) with
| (f, _72_1023) -> begin
(

let _72_1028 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_record_by_field_name env) f)
in (match (_72_1028) with
| (record, _72_1027) -> begin
(

let fields = (FStar_All.pipe_right fields (FStar_List.map (fun _72_1031 -> (match (_72_1031) with
| (f, p) -> begin
(let _173_332 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.qualify_field_to_record env record) f)
in ((_173_332), (p)))
end))))
in (

let args = (FStar_All.pipe_right record.FStar_Parser_DesugarEnv.fields (FStar_List.map (fun _72_1036 -> (match (_72_1036) with
| (f, _72_1035) -> begin
(match ((FStar_All.pipe_right fields (FStar_List.tryFind (fun _72_1040 -> (match (_72_1040) with
| (g, _72_1039) -> begin
(FStar_Ident.lid_equals f g)
end))))) with
| None -> begin
(FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild p.FStar_Parser_AST.prange)
end
| Some (_72_1043, p) -> begin
p
end)
end))))
in (

let app = (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatApp ((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatName (record.FStar_Parser_DesugarEnv.constrname)) p.FStar_Parser_AST.prange)), (args)))) p.FStar_Parser_AST.prange)
in (

let _72_1055 = (aux loc env app)
in (match (_72_1055) with
| (env, e, b, p, _72_1054) -> begin
(

let p = (match (p.FStar_Absyn_Syntax.v) with
| FStar_Absyn_Syntax.Pat_cons (fv, _72_1058, args) -> begin
(let _173_340 = (let _173_339 = (let _173_338 = (let _173_337 = (let _173_336 = (let _173_335 = (FStar_All.pipe_right record.FStar_Parser_DesugarEnv.fields (FStar_List.map Prims.fst))
in ((record.FStar_Parser_DesugarEnv.typename), (_173_335)))
in FStar_Absyn_Syntax.Record_ctor (_173_336))
in Some (_173_337))
in ((fv), (_173_338), (args)))
in FStar_Absyn_Syntax.Pat_cons (_173_339))
in (FStar_All.pipe_left pos _173_340))
end
| _72_1063 -> begin
p
end)
in ((env), (e), (b), (p), (false)))
end)))))
end))
end))
end))))
in (

let _72_1072 = (aux [] env p)
in (match (_72_1072) with
| (_72_1066, env, b, p, _72_1071) -> begin
((env), (b), (p))
end))))))
and desugar_binding_pat_maybe_top : Prims.bool  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Absyn_Syntax.pat Prims.option) = (fun top env p -> if top then begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatVar (x, _72_1078) -> begin
(let _173_346 = (let _173_345 = (let _173_344 = (FStar_Parser_DesugarEnv.qualify env x)
in ((_173_344), (FStar_Absyn_Syntax.tun)))
in LetBinder (_173_345))
in ((env), (_173_346), (None)))
end
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (x, _72_1085); FStar_Parser_AST.prange = _72_1082}, t) -> begin
(let _173_350 = (let _173_349 = (let _173_348 = (FStar_Parser_DesugarEnv.qualify env x)
in (let _173_347 = (desugar_typ env t)
in ((_173_348), (_173_347))))
in LetBinder (_173_349))
in ((env), (_173_350), (None)))
end
| _72_1093 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected pattern at the top-level"), (p.FStar_Parser_AST.prange)))))
end)
end else begin
(

let _72_1097 = (desugar_data_pat env p)
in (match (_72_1097) with
| (env, binder, p) -> begin
(

let p = (match (p.FStar_Absyn_Syntax.v) with
| (FStar_Absyn_Syntax.Pat_var (_)) | (FStar_Absyn_Syntax.Pat_tvar (_)) | (FStar_Absyn_Syntax.Pat_wild (_)) -> begin
None
end
| _72_1108 -> begin
Some (p)
end)
in ((env), (binder), (p)))
end))
end)
and desugar_binding_pat : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.pattern  ->  (env_t * bnd * FStar_Absyn_Syntax.pat Prims.option) = (fun env p -> (desugar_binding_pat_maybe_top false env p))
and desugar_match_pat_maybe_top : Prims.bool  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Absyn_Syntax.pat) = (fun _72_1112 env pat -> (

let _72_1120 = (desugar_data_pat env pat)
in (match (_72_1120) with
| (env, _72_1118, pat) -> begin
((env), (pat))
end)))
and desugar_match_pat : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.pattern  ->  (env_t * FStar_Absyn_Syntax.pat) = (fun env p -> (desugar_match_pat_maybe_top false env p))
and desugar_typ_or_exp : env_t  ->  FStar_Parser_AST.term  ->  (FStar_Absyn_Syntax.typ, FStar_Absyn_Syntax.exp) FStar_Util.either = (fun env t -> if (is_type env t) then begin
(let _173_360 = (desugar_typ env t)
in FStar_Util.Inl (_173_360))
end else begin
(let _173_361 = (desugar_exp env t)
in FStar_Util.Inr (_173_361))
end)
and desugar_exp : env_t  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.exp = (fun env e -> (desugar_exp_maybe_top false env e))
and desugar_name : (FStar_Absyn_Syntax.exp  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax)  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Ident.lident  ->  (FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax = (fun setpos env l -> if (l.FStar_Ident.str = "ref") then begin
(match ((FStar_Parser_DesugarEnv.try_lookup_lid env FStar_Absyn_Const.alloc_lid)) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((("Identifier \'ref\' not found; include lib/FStar.ST.fst in your path"), ((FStar_Ident.range_of_lid l))))))
end
| Some (e) -> begin
(setpos e)
end)
end else begin
(let _173_370 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_lid env) l)
in (FStar_All.pipe_left setpos _173_370))
end)
and desugar_exp_maybe_top : Prims.bool  ->  env_t  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.exp = (fun top_level env top -> (

let pos = (fun e -> (e None top.FStar_Parser_AST.range))
in (

let setpos = (fun e -> (

let _72_1140 = e
in {FStar_Absyn_Syntax.n = _72_1140.FStar_Absyn_Syntax.n; FStar_Absyn_Syntax.tk = _72_1140.FStar_Absyn_Syntax.tk; FStar_Absyn_Syntax.pos = top.FStar_Parser_AST.range; FStar_Absyn_Syntax.fvs = _72_1140.FStar_Absyn_Syntax.fvs; FStar_Absyn_Syntax.uvs = _72_1140.FStar_Absyn_Syntax.uvs}))
in (match ((let _173_388 = (unparen top)
in _173_388.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Const (c) -> begin
(FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Exp_constant c))
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((op_as_vlid env (FStar_List.length args) top.FStar_Parser_AST.range s)) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Unexpected operator: " s)), (top.FStar_Parser_AST.range)))))
end
| Some (l) -> begin
(

let op = (FStar_Absyn_Util.fvar None l (FStar_Ident.range_of_lid l))
in (

let args = (FStar_All.pipe_right args (FStar_List.map (fun t -> (let _173_392 = (desugar_typ_or_exp env t)
in ((_173_392), (None))))))
in (let _173_393 = (FStar_Absyn_Util.mk_exp_app op args)
in (FStar_All.pipe_left setpos _173_393))))
end)
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) -> begin
(desugar_name setpos env l)
end
| FStar_Parser_AST.Construct (l, args) -> begin
(

let dt = (let _173_398 = (let _173_397 = (let _173_396 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_datacon env) l)
in ((_173_396), (Some (FStar_Absyn_Syntax.Data_ctor))))
in (FStar_Absyn_Syntax.mk_Exp_fvar _173_397))
in (FStar_All.pipe_left pos _173_398))
in (match (args) with
| [] -> begin
dt
end
| _72_1164 -> begin
(

let args = (FStar_List.map (fun _72_1167 -> (match (_72_1167) with
| (t, imp) -> begin
(

let te = (desugar_typ_or_exp env t)
in (arg_withimp_e imp te))
end)) args)
in (let _173_403 = (let _173_402 = (let _173_401 = (let _173_400 = (FStar_Absyn_Util.mk_exp_app dt args)
in ((_173_400), (FStar_Absyn_Syntax.Data_app)))
in FStar_Absyn_Syntax.Meta_desugared (_173_401))
in (FStar_Absyn_Syntax.mk_Exp_meta _173_402))
in (FStar_All.pipe_left setpos _173_403)))
end))
end
| FStar_Parser_AST.Abs (binders, body) -> begin
(

let _72_1204 = (FStar_List.fold_left (fun _72_1176 pat -> (match (_72_1176) with
| (env, ftvs) -> begin
(match (pat.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatTvar (a, imp); FStar_Parser_AST.prange = _72_1179}, t) -> begin
(

let ftvs = (let _173_406 = (free_type_vars env t)
in (FStar_List.append _173_406 ftvs))
in (let _173_408 = (let _173_407 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (FStar_All.pipe_left Prims.fst _173_407))
in ((_173_408), (ftvs))))
end
| FStar_Parser_AST.PatTvar (a, _72_1191) -> begin
(let _173_410 = (let _173_409 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (FStar_All.pipe_left Prims.fst _173_409))
in ((_173_410), (ftvs)))
end
| FStar_Parser_AST.PatAscribed (_72_1195, t) -> begin
(let _173_412 = (let _173_411 = (free_type_vars env t)
in (FStar_List.append _173_411 ftvs))
in ((env), (_173_412)))
end
| _72_1200 -> begin
((env), (ftvs))
end)
end)) ((env), ([])) binders)
in (match (_72_1204) with
| (_72_1202, ftv) -> begin
(

let ftv = (sort_ftv ftv)
in (

let binders = (let _173_414 = (FStar_All.pipe_right ftv (FStar_List.map (fun a -> (FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatTvar (((a), (Some (FStar_Parser_AST.Implicit))))) top.FStar_Parser_AST.range))))
in (FStar_List.append _173_414 binders))
in (

let rec aux = (fun env bs sc_pat_opt uu___415 -> (match (uu___415) with
| [] -> begin
(

let body = (desugar_exp env body)
in (

let body = (match (sc_pat_opt) with
| Some (sc, pat) -> begin
(FStar_Absyn_Syntax.mk_Exp_match ((sc), ((((pat), (None), (body)))::[])) None body.FStar_Absyn_Syntax.pos)
end
| None -> begin
body
end)
in (FStar_Absyn_Syntax.mk_Exp_abs' (((FStar_List.rev bs)), (body)) None top.FStar_Parser_AST.range)))
end
| (p)::rest -> begin
(

let _72_1227 = (desugar_binding_pat env p)
in (match (_72_1227) with
| (env, b, pat) -> begin
(

let _72_1287 = (match (b) with
| LetBinder (_72_1229) -> begin
(failwith "Impossible")
end
| TBinder (a, k, aq) -> begin
(let _173_423 = (binder_of_bnd b)
in ((_173_423), (sc_pat_opt)))
end
| VBinder (x, t, aq) -> begin
(

let b = (FStar_Absyn_Util.bvd_to_bvar_s x t)
in (

let sc_pat_opt = (match (((pat), (sc_pat_opt))) with
| (None, _72_1244) -> begin
sc_pat_opt
end
| (Some (p), None) -> begin
(let _173_425 = (let _173_424 = (FStar_Absyn_Util.bvar_to_exp b)
in ((_173_424), (p)))
in Some (_173_425))
end
| (Some (p), Some (sc, p')) -> begin
(match (((sc.FStar_Absyn_Syntax.n), (p'.FStar_Absyn_Syntax.v))) with
| (FStar_Absyn_Syntax.Exp_bvar (_72_1258), _72_1261) -> begin
(

let tup = (FStar_Absyn_Util.mk_tuple_data_lid (Prims.parse_int "2") top.FStar_Parser_AST.range)
in (

let sc = (let _173_432 = (let _173_431 = (FStar_Absyn_Util.fvar (Some (FStar_Absyn_Syntax.Data_ctor)) tup top.FStar_Parser_AST.range)
in (let _173_430 = (let _173_429 = (FStar_Absyn_Syntax.varg sc)
in (let _173_428 = (let _173_427 = (let _173_426 = (FStar_Absyn_Util.bvar_to_exp b)
in (FStar_All.pipe_left FStar_Absyn_Syntax.varg _173_426))
in (_173_427)::[])
in (_173_429)::_173_428))
in ((_173_431), (_173_430))))
in (FStar_Absyn_Syntax.mk_Exp_app _173_432 None top.FStar_Parser_AST.range))
in (

let p = (let _173_433 = (FStar_Range.union_ranges p'.FStar_Absyn_Syntax.p p.FStar_Absyn_Syntax.p)
in (FStar_Absyn_Util.withinfo (FStar_Absyn_Syntax.Pat_cons ((((FStar_Absyn_Util.fv tup)), (Some (FStar_Absyn_Syntax.Data_ctor)), ((((p'), (false)))::(((p), (false)))::[])))) None _173_433))
in Some (((sc), (p))))))
end
| (FStar_Absyn_Syntax.Exp_app (_72_1267, args), FStar_Absyn_Syntax.Pat_cons (_72_1272, _72_1274, pats)) -> begin
(

let tup = (FStar_Absyn_Util.mk_tuple_data_lid ((Prims.parse_int "1") + (FStar_List.length args)) top.FStar_Parser_AST.range)
in (

let sc = (let _173_439 = (let _173_438 = (FStar_Absyn_Util.fvar (Some (FStar_Absyn_Syntax.Data_ctor)) tup top.FStar_Parser_AST.range)
in (let _173_437 = (let _173_436 = (let _173_435 = (let _173_434 = (FStar_Absyn_Util.bvar_to_exp b)
in (FStar_All.pipe_left FStar_Absyn_Syntax.varg _173_434))
in (_173_435)::[])
in (FStar_List.append args _173_436))
in ((_173_438), (_173_437))))
in (FStar_Absyn_Syntax.mk_Exp_app _173_439 None top.FStar_Parser_AST.range))
in (

let p = (let _173_440 = (FStar_Range.union_ranges p'.FStar_Absyn_Syntax.p p.FStar_Absyn_Syntax.p)
in (FStar_Absyn_Util.withinfo (FStar_Absyn_Syntax.Pat_cons ((((FStar_Absyn_Util.fv tup)), (Some (FStar_Absyn_Syntax.Data_ctor)), ((FStar_List.append pats ((((p), (false)))::[])))))) None _173_440))
in Some (((sc), (p))))))
end
| _72_1283 -> begin
(failwith "Impossible")
end)
end)
in ((((FStar_Util.Inr (b)), (aq))), (sc_pat_opt))))
end)
in (match (_72_1287) with
| (b, sc_pat_opt) -> begin
(aux env ((b)::bs) sc_pat_opt rest)
end))
end))
end))
in (aux env [] None binders))))
end))
end
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (a); FStar_Parser_AST.range = _72_1291; FStar_Parser_AST.level = _72_1289}, arg, _72_1297) when ((FStar_Ident.lid_equals a FStar_Absyn_Const.assert_lid) || (FStar_Ident.lid_equals a FStar_Absyn_Const.assume_lid)) -> begin
(

let phi = (desugar_formula env arg)
in (let _173_450 = (let _173_449 = (let _173_448 = (FStar_Absyn_Util.fvar None a (FStar_Ident.range_of_lid a))
in (let _173_447 = (let _173_446 = (FStar_All.pipe_left FStar_Absyn_Syntax.targ phi)
in (let _173_445 = (let _173_444 = (let _173_443 = (FStar_Absyn_Syntax.mk_Exp_constant FStar_Const.Const_unit None top.FStar_Parser_AST.range)
in (FStar_All.pipe_left FStar_Absyn_Syntax.varg _173_443))
in (_173_444)::[])
in (_173_446)::_173_445))
in ((_173_448), (_173_447))))
in (FStar_Absyn_Syntax.mk_Exp_app _173_449))
in (FStar_All.pipe_left pos _173_450)))
end
| FStar_Parser_AST.App (_72_1302) -> begin
(

let rec aux = (fun args e -> (match ((let _173_455 = (unparen e)
in _173_455.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (e, t, imp) -> begin
(

let arg = (let _173_456 = (desugar_typ_or_exp env t)
in (FStar_All.pipe_left (arg_withimp_e imp) _173_456))
in (aux ((arg)::args) e))
end
| _72_1314 -> begin
(

let head = (desugar_exp env e)
in (FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Exp_app ((head), (args)))))
end))
in (aux [] top))
end
| FStar_Parser_AST.Seq (t1, t2) -> begin
(let _173_462 = (let _173_461 = (let _173_460 = (let _173_459 = (desugar_exp env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern FStar_Parser_AST.PatWild t1.FStar_Parser_AST.range)), (t1)))::[]), (t2)))) top.FStar_Parser_AST.range FStar_Parser_AST.Expr))
in ((_173_459), (FStar_Absyn_Syntax.Sequence)))
in FStar_Absyn_Syntax.Meta_desugared (_173_460))
in (FStar_Absyn_Syntax.mk_Exp_meta _173_461))
in (FStar_All.pipe_left setpos _173_462))
end
| FStar_Parser_AST.LetOpen (_72_1321) -> begin
(failwith "let open in universes")
end
| FStar_Parser_AST.Let (is_rec, ((pat, _snd))::_tl, body) -> begin
(

let is_rec = (is_rec = FStar_Parser_AST.Rec)
in (

let ds_let_rec = (fun _72_1334 -> (match (()) with
| () -> begin
(

let bindings = (((pat), (_snd)))::_tl
in (

let funs = (FStar_All.pipe_right bindings (FStar_List.map (fun _72_1338 -> (match (_72_1338) with
| (p, def) -> begin
if (is_app_pattern p) then begin
(let _173_466 = (destruct_app_pattern env top_level p)
in ((_173_466), (def)))
end else begin
(match ((FStar_Parser_AST.un_function p def)) with
| Some (p, def) -> begin
(let _173_467 = (destruct_app_pattern env top_level p)
in ((_173_467), (def)))
end
| _72_1344 -> begin
(match (p.FStar_Parser_AST.pat) with
| FStar_Parser_AST.PatAscribed ({FStar_Parser_AST.pat = FStar_Parser_AST.PatVar (id, _72_1349); FStar_Parser_AST.prange = _72_1346}, t) -> begin
if top_level then begin
(let _173_470 = (let _173_469 = (let _173_468 = (FStar_Parser_DesugarEnv.qualify env id)
in FStar_Util.Inr (_173_468))
in ((_173_469), ([]), (Some (t))))
in ((_173_470), (def)))
end else begin
((((FStar_Util.Inl (id)), ([]), (Some (t)))), (def))
end
end
| FStar_Parser_AST.PatVar (id, _72_1358) -> begin
if top_level then begin
(let _173_473 = (let _173_472 = (let _173_471 = (FStar_Parser_DesugarEnv.qualify env id)
in FStar_Util.Inr (_173_471))
in ((_173_472), ([]), (None)))
in ((_173_473), (def)))
end else begin
((((FStar_Util.Inl (id)), ([]), (None))), (def))
end
end
| _72_1362 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected let binding"), (p.FStar_Parser_AST.prange)))))
end)
end)
end
end))))
in (

let _72_1388 = (FStar_List.fold_left (fun _72_1366 _72_1375 -> (match (((_72_1366), (_72_1375))) with
| ((env, fnames), ((f, _72_1369, _72_1371), _72_1374)) -> begin
(

let _72_1385 = (match (f) with
| FStar_Util.Inl (x) -> begin
(

let _72_1380 = (FStar_Parser_DesugarEnv.push_local_vbinding env x)
in (match (_72_1380) with
| (env, xx) -> begin
((env), (FStar_Util.Inl (xx)))
end))
end
| FStar_Util.Inr (l) -> begin
(let _173_476 = (FStar_Parser_DesugarEnv.push_rec_binding env (FStar_Parser_DesugarEnv.Binding_let (l)))
in ((_173_476), (FStar_Util.Inr (l))))
end)
in (match (_72_1385) with
| (env, lbname) -> begin
((env), ((lbname)::fnames))
end))
end)) ((env), ([])) funs)
in (match (_72_1388) with
| (env', fnames) -> begin
(

let fnames = (FStar_List.rev fnames)
in (

let desugar_one_def = (fun env lbname _72_1399 -> (match (_72_1399) with
| ((_72_1394, args, result_t), def) -> begin
(

let def = (match (result_t) with
| None -> begin
def
end
| Some (t) -> begin
(let _173_483 = (FStar_Range.union_ranges t.FStar_Parser_AST.range def.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term (FStar_Parser_AST.Ascribed (((def), (t)))) _173_483 FStar_Parser_AST.Expr))
end)
in (

let def = (match (args) with
| [] -> begin
def
end
| _72_1406 -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.un_curry_abs args def) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
end)
in (

let body = (desugar_exp env def)
in (mk_lb ((lbname), (FStar_Absyn_Syntax.tun), (body))))))
end))
in (

let lbs = (FStar_List.map2 (desugar_one_def (if is_rec then begin
env'
end else begin
env
end)) fnames funs)
in (

let body = (desugar_exp env' body)
in (FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Exp_let ((((is_rec), (lbs))), (body))))))))
end))))
end))
in (

let ds_non_rec = (fun pat t1 t2 -> (

let t1 = (desugar_exp env t1)
in (

let _72_1419 = (desugar_binding_pat_maybe_top top_level env pat)
in (match (_72_1419) with
| (env, binder, pat) -> begin
(match (binder) with
| TBinder (_72_1421) -> begin
(failwith "Unexpected type binder in let")
end
| LetBinder (l, t) -> begin
(

let body = (desugar_exp env t2)
in (FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Exp_let ((((false), (({FStar_Absyn_Syntax.lbname = FStar_Util.Inr (l); FStar_Absyn_Syntax.lbtyp = t; FStar_Absyn_Syntax.lbeff = FStar_Absyn_Const.effect_ALL_lid; FStar_Absyn_Syntax.lbdef = t1})::[]))), (body)))))
end
| VBinder (x, t, _72_1431) -> begin
(

let body = (desugar_exp env t2)
in (

let body = (match (pat) with
| (None) | (Some ({FStar_Absyn_Syntax.v = FStar_Absyn_Syntax.Pat_wild (_); FStar_Absyn_Syntax.sort = _; FStar_Absyn_Syntax.p = _})) -> begin
body
end
| Some (pat) -> begin
(let _173_495 = (let _173_494 = (FStar_Absyn_Util.bvd_to_exp x t)
in ((_173_494), ((((pat), (None), (body)))::[])))
in (FStar_Absyn_Syntax.mk_Exp_match _173_495 None body.FStar_Absyn_Syntax.pos))
end)
in (FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Exp_let ((((false), (((mk_lb ((FStar_Util.Inl (x)), (t), (t1))))::[]))), (body))))))
end)
end))))
in if (is_rec || (is_app_pattern pat)) then begin
(ds_let_rec ())
end else begin
(ds_non_rec pat _snd body)
end)))
end
| FStar_Parser_AST.If (t1, t2, t3) -> begin
(let _173_508 = (let _173_507 = (let _173_506 = (desugar_exp env t1)
in (let _173_505 = (let _173_504 = (let _173_500 = (desugar_exp env t2)
in (((FStar_Absyn_Util.withinfo (FStar_Absyn_Syntax.Pat_constant (FStar_Const.Const_bool (true))) None t2.FStar_Parser_AST.range)), (None), (_173_500)))
in (let _173_503 = (let _173_502 = (let _173_501 = (desugar_exp env t3)
in (((FStar_Absyn_Util.withinfo (FStar_Absyn_Syntax.Pat_constant (FStar_Const.Const_bool (false))) None t3.FStar_Parser_AST.range)), (None), (_173_501)))
in (_173_502)::[])
in (_173_504)::_173_503))
in ((_173_506), (_173_505))))
in (FStar_Absyn_Syntax.mk_Exp_match _173_507))
in (FStar_All.pipe_left pos _173_508))
end
| FStar_Parser_AST.TryWith (e, branches) -> begin
(

let r = top.FStar_Parser_AST.range
in (

let handler = (FStar_Parser_AST.mk_function branches r r)
in (

let body = (FStar_Parser_AST.mk_function (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatConst (FStar_Const.Const_unit)) r)), (None), (e)))::[]) r r)
in (

let a1 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Var (FStar_Absyn_Const.try_with_lid)) r top.FStar_Parser_AST.level)), (body), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (

let a2 = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((a1), (handler), (FStar_Parser_AST.Nothing)))) r top.FStar_Parser_AST.level)
in (desugar_exp env a2))))))
end
| FStar_Parser_AST.Match (e, branches) -> begin
(

let desugar_branch = (fun _72_1470 -> (match (_72_1470) with
| (pat, wopt, b) -> begin
(

let _72_1473 = (desugar_match_pat env pat)
in (match (_72_1473) with
| (env, pat) -> begin
(

let wopt = (match (wopt) with
| None -> begin
None
end
| Some (e) -> begin
(let _173_511 = (desugar_exp env e)
in Some (_173_511))
end)
in (

let b = (desugar_exp env b)
in ((pat), (wopt), (b))))
end))
end))
in (let _173_517 = (let _173_516 = (let _173_515 = (desugar_exp env e)
in (let _173_514 = (FStar_List.map desugar_branch branches)
in ((_173_515), (_173_514))))
in (FStar_Absyn_Syntax.mk_Exp_match _173_516))
in (FStar_All.pipe_left pos _173_517)))
end
| FStar_Parser_AST.Ascribed (e, t) -> begin
(let _173_523 = (let _173_522 = (let _173_521 = (desugar_exp env e)
in (let _173_520 = (desugar_typ env t)
in ((_173_521), (_173_520), (None))))
in (FStar_Absyn_Syntax.mk_Exp_ascribed _173_522))
in (FStar_All.pipe_left pos _173_523))
end
| FStar_Parser_AST.Record (_72_1484, []) -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected empty record"), (top.FStar_Parser_AST.range)))))
end
| FStar_Parser_AST.Record (eopt, fields) -> begin
(

let _72_1495 = (FStar_List.hd fields)
in (match (_72_1495) with
| (f, _72_1494) -> begin
(

let qfn = (fun g -> (FStar_Ident.lid_of_ids (FStar_List.append f.FStar_Ident.ns ((g)::[]))))
in (

let _72_1501 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_record_by_field_name env) f)
in (match (_72_1501) with
| (record, _72_1500) -> begin
(

let get_field = (fun xopt f -> (

let fn = f.FStar_Ident.ident
in (

let found = (FStar_All.pipe_right fields (FStar_Util.find_opt (fun _72_1509 -> (match (_72_1509) with
| (g, _72_1508) -> begin
(

let gn = g.FStar_Ident.ident
in (fn.FStar_Ident.idText = gn.FStar_Ident.idText))
end))))
in (match (found) with
| Some (_72_1513, e) -> begin
(let _173_531 = (qfn fn)
in ((_173_531), (e)))
end
| None -> begin
(match (xopt) with
| None -> begin
(let _173_534 = (let _173_533 = (let _173_532 = (FStar_Util.format1 "Field %s is missing" (FStar_Ident.text_of_lid f))
in ((_173_532), (top.FStar_Parser_AST.range)))
in FStar_Errors.Error (_173_533))
in (Prims.raise _173_534))
end
| Some (x) -> begin
(let _173_535 = (qfn fn)
in ((_173_535), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Project (((x), (f)))) x.FStar_Parser_AST.range x.FStar_Parser_AST.level))))
end)
end))))
in (

let recterm = (match (eopt) with
| None -> begin
(let _173_540 = (let _173_539 = (FStar_All.pipe_right record.FStar_Parser_DesugarEnv.fields (FStar_List.map (fun _72_1525 -> (match (_72_1525) with
| (f, _72_1524) -> begin
(let _173_538 = (let _173_537 = (get_field None f)
in (FStar_All.pipe_left Prims.snd _173_537))
in ((_173_538), (FStar_Parser_AST.Nothing)))
end))))
in ((record.FStar_Parser_DesugarEnv.constrname), (_173_539)))
in FStar_Parser_AST.Construct (_173_540))
end
| Some (e) -> begin
(

let x = (FStar_Absyn_Util.genident (Some (e.FStar_Parser_AST.range)))
in (

let xterm = (let _173_542 = (let _173_541 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_173_541))
in (FStar_Parser_AST.mk_term _173_542 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
in (

let record = (let _173_545 = (let _173_544 = (FStar_All.pipe_right record.FStar_Parser_DesugarEnv.fields (FStar_List.map (fun _72_1533 -> (match (_72_1533) with
| (f, _72_1532) -> begin
(get_field (Some (xterm)) f)
end))))
in ((None), (_173_544)))
in FStar_Parser_AST.Record (_173_545))
in FStar_Parser_AST.Let (((FStar_Parser_AST.NoLetQualifier), (((((FStar_Parser_AST.mk_pattern (FStar_Parser_AST.PatVar (((x), (None)))) x.FStar_Ident.idRange)), (e)))::[]), ((FStar_Parser_AST.mk_term record top.FStar_Parser_AST.range top.FStar_Parser_AST.level)))))))
end)
in (

let recterm = (FStar_Parser_AST.mk_term recterm top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
in (

let e = (desugar_exp env recterm)
in (match (e.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Exp_meta (FStar_Absyn_Syntax.Meta_desugared ({FStar_Absyn_Syntax.n = FStar_Absyn_Syntax.Exp_app ({FStar_Absyn_Syntax.n = FStar_Absyn_Syntax.Exp_fvar (fv, _72_1556); FStar_Absyn_Syntax.tk = _72_1553; FStar_Absyn_Syntax.pos = _72_1551; FStar_Absyn_Syntax.fvs = _72_1549; FStar_Absyn_Syntax.uvs = _72_1547}, args); FStar_Absyn_Syntax.tk = _72_1545; FStar_Absyn_Syntax.pos = _72_1543; FStar_Absyn_Syntax.fvs = _72_1541; FStar_Absyn_Syntax.uvs = _72_1539}, FStar_Absyn_Syntax.Data_app)) -> begin
(

let e = (let _173_555 = (let _173_554 = (let _173_553 = (let _173_552 = (let _173_551 = (let _173_550 = (let _173_549 = (let _173_548 = (FStar_All.pipe_right record.FStar_Parser_DesugarEnv.fields (FStar_List.map Prims.fst))
in ((record.FStar_Parser_DesugarEnv.typename), (_173_548)))
in FStar_Absyn_Syntax.Record_ctor (_173_549))
in Some (_173_550))
in ((fv), (_173_551)))
in (FStar_Absyn_Syntax.mk_Exp_fvar _173_552 None e.FStar_Absyn_Syntax.pos))
in ((_173_553), (args)))
in (FStar_Absyn_Syntax.mk_Exp_app _173_554))
in (FStar_All.pipe_left pos _173_555))
in (FStar_Absyn_Syntax.mk_Exp_meta (FStar_Absyn_Syntax.Meta_desugared (((e), (FStar_Absyn_Syntax.Data_app))))))
end
| _72_1570 -> begin
e
end)))))
end)))
end))
end
| FStar_Parser_AST.Project (e, f) -> begin
(

let _72_1577 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_projector_by_field_name env) f)
in (match (_72_1577) with
| (fieldname, is_rec) -> begin
(

let e = (desugar_exp env e)
in (

let fn = (

let _72_1582 = (FStar_Util.prefix fieldname.FStar_Ident.ns)
in (match (_72_1582) with
| (ns, _72_1581) -> begin
(FStar_Ident.lid_of_ids (FStar_List.append ns ((f.FStar_Ident.ident)::[])))
end))
in (

let qual = if is_rec then begin
Some (FStar_Absyn_Syntax.Record_projector (fn))
end else begin
None
end
in (let _173_562 = (let _173_561 = (let _173_560 = (FStar_Absyn_Util.fvar qual fieldname (FStar_Ident.range_of_lid f))
in (let _173_559 = (let _173_558 = (FStar_Absyn_Syntax.varg e)
in (_173_558)::[])
in ((_173_560), (_173_559))))
in (FStar_Absyn_Syntax.mk_Exp_app _173_561))
in (FStar_All.pipe_left pos _173_562)))))
end))
end
| FStar_Parser_AST.Paren (e) -> begin
(desugar_exp env e)
end
| FStar_Parser_AST.Projector (ns, id) -> begin
(

let l = (FStar_Parser_DesugarEnv.qual ns id)
in (desugar_name setpos env l))
end
| FStar_Parser_AST.Discrim (lid) -> begin
(

let lid' = (FStar_Absyn_Util.mk_discriminator lid)
in (desugar_name setpos env lid'))
end
| _72_1596 -> begin
(FStar_Parser_AST.error "Unexpected term" top top.FStar_Parser_AST.range)
end))))
and desugar_typ : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.typ = (fun env top -> (

let wpos = (fun t -> (t None top.FStar_Parser_AST.range))
in (

let setpos = (fun t -> (

let _72_1603 = t
in {FStar_Absyn_Syntax.n = _72_1603.FStar_Absyn_Syntax.n; FStar_Absyn_Syntax.tk = _72_1603.FStar_Absyn_Syntax.tk; FStar_Absyn_Syntax.pos = top.FStar_Parser_AST.range; FStar_Absyn_Syntax.fvs = _72_1603.FStar_Absyn_Syntax.fvs; FStar_Absyn_Syntax.uvs = _72_1603.FStar_Absyn_Syntax.uvs}))
in (

let top = (unparen top)
in (

let head_and_args = (fun t -> (

let rec aux = (fun args t -> (match ((let _173_585 = (unparen t)
in _173_585.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (t, arg, imp) -> begin
(aux ((((arg), (imp)))::args) t)
end
| FStar_Parser_AST.Construct (l, args') -> begin
(({FStar_Parser_AST.tm = FStar_Parser_AST.Name (l); FStar_Parser_AST.range = t.FStar_Parser_AST.range; FStar_Parser_AST.level = t.FStar_Parser_AST.level}), ((FStar_List.append args' args)))
end
| _72_1621 -> begin
((t), (args))
end))
in (aux [] t)))
in (match (top.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Wild -> begin
(setpos FStar_Absyn_Syntax.tun)
end
| FStar_Parser_AST.Requires (t, lopt) -> begin
(

let t = (label_conjuncts "pre-condition" true lopt t)
in if (is_type env t) then begin
(desugar_typ env t)
end else begin
(let _173_586 = (desugar_exp env t)
in (FStar_All.pipe_right _173_586 FStar_Absyn_Util.b2t))
end)
end
| FStar_Parser_AST.Ensures (t, lopt) -> begin
(

let t = (label_conjuncts "post-condition" false lopt t)
in if (is_type env t) then begin
(desugar_typ env t)
end else begin
(let _173_587 = (desugar_exp env t)
in (FStar_All.pipe_right _173_587 FStar_Absyn_Util.b2t))
end)
end
| FStar_Parser_AST.Op ("*", (t1)::(_72_1635)::[]) -> begin
if (is_type env t1) then begin
(

let rec flatten = (fun t -> (match (t.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Op ("*", (t1)::(t2)::[]) -> begin
(let _173_590 = (flatten t1)
in (FStar_List.append _173_590 ((t2)::[])))
end
| _72_1649 -> begin
(t)::[]
end))
in (

let targs = (let _173_593 = (flatten top)
in (FStar_All.pipe_right _173_593 (FStar_List.map (fun t -> (let _173_592 = (desugar_typ env t)
in (FStar_Absyn_Syntax.targ _173_592))))))
in (

let tup = (let _173_594 = (FStar_Absyn_Util.mk_tuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) _173_594))
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_app ((tup), (targs)))))))
end else begin
(let _173_600 = (let _173_599 = (let _173_598 = (let _173_597 = (FStar_Parser_AST.term_to_string t1)
in (FStar_Util.format1 "The operator \"*\" is resolved here as multiplication since \"%s\" is a term, although a type was expected" _173_597))
in ((_173_598), (top.FStar_Parser_AST.range)))
in FStar_Errors.Error (_173_599))
in (Prims.raise _173_600))
end
end
| FStar_Parser_AST.Op ("=!=", args) -> begin
(desugar_typ env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("~"), (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Op ((("=="), (args)))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))::[])))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level))
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((op_as_tylid env (FStar_List.length args) top.FStar_Parser_AST.range s)) with
| None -> begin
(let _173_601 = (desugar_exp env top)
in (FStar_All.pipe_right _173_601 FStar_Absyn_Util.b2t))
end
| Some (l) -> begin
(

let args = (FStar_List.map (fun t -> (let _173_603 = (desugar_typ_or_exp env t)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _173_603))) args)
in (let _173_604 = (FStar_Absyn_Util.ftv l FStar_Absyn_Syntax.kun)
in (FStar_Absyn_Util.mk_typ_app _173_604 args)))
end)
end
| FStar_Parser_AST.Tvar (a) -> begin
(let _173_605 = (FStar_Parser_DesugarEnv.fail_or2 (FStar_Parser_DesugarEnv.try_lookup_typ_var env) a)
in (FStar_All.pipe_left setpos _173_605))
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) when ((FStar_List.length l.FStar_Ident.ns) = (Prims.parse_int "0")) -> begin
(match ((FStar_Parser_DesugarEnv.try_lookup_typ_var env l.FStar_Ident.ident)) with
| Some (t) -> begin
(setpos t)
end
| None -> begin
(let _173_606 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) l)
in (FStar_All.pipe_left setpos _173_606))
end)
end
| (FStar_Parser_AST.Var (l)) | (FStar_Parser_AST.Name (l)) -> begin
(

let l = (FStar_Absyn_Util.set_lid_range l top.FStar_Parser_AST.range)
in (let _173_607 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) l)
in (FStar_All.pipe_left setpos _173_607)))
end
| FStar_Parser_AST.Construct (l, args) -> begin
(

let t = (let _173_608 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) l)
in (FStar_All.pipe_left setpos _173_608))
in (

let args = (FStar_List.map (fun _72_1685 -> (match (_72_1685) with
| (t, imp) -> begin
(let _173_610 = (desugar_typ_or_exp env t)
in (FStar_All.pipe_left (arg_withimp_t imp) _173_610))
end)) args)
in (FStar_Absyn_Util.mk_typ_app t args)))
end
| FStar_Parser_AST.Abs (binders, body) -> begin
(

let rec aux = (fun env bs uu___416 -> (match (uu___416) with
| [] -> begin
(

let body = (desugar_typ env body)
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_lam (((FStar_List.rev bs)), (body)))))
end
| (hd)::tl -> begin
(

let _72_1703 = (desugar_binding_pat env hd)
in (match (_72_1703) with
| (env, bnd, pat) -> begin
(match (pat) with
| Some (q) -> begin
(let _173_622 = (let _173_621 = (let _173_620 = (let _173_619 = (FStar_Absyn_Print.pat_to_string q)
in (FStar_Util.format1 "Pattern matching at the type level is not supported; got %s\n" _173_619))
in ((_173_620), (hd.FStar_Parser_AST.prange)))
in FStar_Errors.Error (_173_621))
in (Prims.raise _173_622))
end
| None -> begin
(

let b = (binder_of_bnd bnd)
in (aux env ((b)::bs) tl))
end)
end))
end))
in (aux env [] binders))
end
| FStar_Parser_AST.App (_72_1709) -> begin
(

let rec aux = (fun args e -> (match ((let _173_627 = (unparen e)
in _173_627.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App (e, arg, imp) -> begin
(

let arg = (let _173_628 = (desugar_typ_or_exp env arg)
in (FStar_All.pipe_left (arg_withimp_t imp) _173_628))
in (aux ((arg)::args) e))
end
| _72_1721 -> begin
(

let head = (desugar_typ env e)
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_app ((head), (args)))))
end))
in (aux [] top))
end
| FStar_Parser_AST.Product ([], t) -> begin
(failwith "Impossible: product with no binders")
end
| FStar_Parser_AST.Product (binders, t) -> begin
(

let _72_1733 = (uncurry binders t)
in (match (_72_1733) with
| (bs, t) -> begin
(

let rec aux = (fun env bs uu___417 -> (match (uu___417) with
| [] -> begin
(

let cod = (desugar_comp top.FStar_Parser_AST.range true env t)
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_fun (((FStar_List.rev bs)), (cod)))))
end
| (hd)::tl -> begin
(

let mlenv = (FStar_Parser_DesugarEnv.default_ml env)
in (

let bb = (desugar_binder mlenv hd)
in (

let _72_1747 = (as_binder env hd.FStar_Parser_AST.aqual bb)
in (match (_72_1747) with
| (b, env) -> begin
(aux env ((b)::bs) tl)
end))))
end))
in (aux env [] bs))
end))
end
| FStar_Parser_AST.Refine (b, f) -> begin
(match ((desugar_exp_binder env b)) with
| (None, _72_1754) -> begin
(failwith "Missing binder in refinement")
end
| b -> begin
(

let _72_1768 = (match ((as_binder env None (FStar_Util.Inr (b)))) with
| ((FStar_Util.Inr (x), _72_1760), env) -> begin
((x), (env))
end
| _72_1765 -> begin
(failwith "impossible")
end)
in (match (_72_1768) with
| (b, env) -> begin
(

let f = if (is_type env f) then begin
(desugar_formula env f)
end else begin
(let _173_639 = (desugar_exp env f)
in (FStar_All.pipe_right _173_639 FStar_Absyn_Util.b2t))
end
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_refine ((b), (f)))))
end))
end)
end
| (FStar_Parser_AST.NamedTyp (_, t)) | (FStar_Parser_AST.Paren (t)) -> begin
(desugar_typ env t)
end
| FStar_Parser_AST.Ascribed (t, k) -> begin
(let _173_647 = (let _173_646 = (let _173_645 = (desugar_typ env t)
in (let _173_644 = (desugar_kind env k)
in ((_173_645), (_173_644))))
in (FStar_Absyn_Syntax.mk_Typ_ascribed' _173_646))
in (FStar_All.pipe_left wpos _173_647))
end
| FStar_Parser_AST.Sum (binders, t) -> begin
(

let _72_1802 = (FStar_List.fold_left (fun _72_1787 b -> (match (_72_1787) with
| (env, tparams, typs) -> begin
(

let _72_1791 = (desugar_exp_binder env b)
in (match (_72_1791) with
| (xopt, t) -> begin
(

let _72_1797 = (match (xopt) with
| None -> begin
(let _173_650 = (FStar_Absyn_Util.new_bvd (Some (top.FStar_Parser_AST.range)))
in ((env), (_173_650)))
end
| Some (x) -> begin
(FStar_Parser_DesugarEnv.push_local_vbinding env x)
end)
in (match (_72_1797) with
| (env, x) -> begin
(let _173_654 = (let _173_653 = (let _173_652 = (let _173_651 = (FStar_Absyn_Util.close_with_lam tparams t)
in (FStar_All.pipe_left FStar_Absyn_Syntax.targ _173_651))
in (_173_652)::[])
in (FStar_List.append typs _173_653))
in ((env), ((FStar_List.append tparams ((((FStar_Util.Inr ((FStar_Absyn_Util.bvd_to_bvar_s x t))), (None)))::[]))), (_173_654)))
end))
end))
end)) ((env), ([]), ([])) (FStar_List.append binders (((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level None))::[])))
in (match (_72_1802) with
| (env, _72_1800, targs) -> begin
(

let tup = (let _173_655 = (FStar_Absyn_Util.mk_dtuple_lid (FStar_List.length targs) top.FStar_Parser_AST.range)
in (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) _173_655))
in (FStar_All.pipe_left wpos (FStar_Absyn_Syntax.mk_Typ_app ((tup), (targs)))))
end))
end
| FStar_Parser_AST.Record (_72_1805) -> begin
(failwith "Unexpected record type")
end
| FStar_Parser_AST.Let (FStar_Parser_AST.NoLetQualifier, ((x, v))::[], t) -> begin
(

let let_v = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.let_in_typ)) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)), (v), (FStar_Parser_AST.Nothing)))) v.FStar_Parser_AST.range v.FStar_Parser_AST.level)
in (

let t' = (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((let_v), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Abs ((((x)::[]), (t)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)), (FStar_Parser_AST.Nothing)))) top.FStar_Parser_AST.range top.FStar_Parser_AST.level)
in (desugar_typ env t')))
end
| (FStar_Parser_AST.If (_)) | (FStar_Parser_AST.Labeled (_)) -> begin
(desugar_formula env top)
end
| _72_1824 when (top.FStar_Parser_AST.level = FStar_Parser_AST.Formula) -> begin
(desugar_formula env top)
end
| _72_1826 -> begin
(FStar_Parser_AST.error "Expected a type" top top.FStar_Parser_AST.range)
end))))))
and desugar_comp : FStar_Range.range  ->  Prims.bool  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.comp = (fun r default_ok env t -> (

let fail = (fun msg -> (Prims.raise (FStar_Errors.Error (((msg), (r))))))
in (

let pre_process_comp_typ = (fun t -> (

let _72_1837 = (head_and_args t)
in (match (_72_1837) with
| (head, args) -> begin
(match (head.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name (lemma) when (lemma.FStar_Ident.ident.FStar_Ident.idText = "Lemma") -> begin
(

let unit = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.unit_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level)), (FStar_Parser_AST.Nothing))
in (

let nil_pat = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.nil_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Expr)), (FStar_Parser_AST.Nothing))
in (

let _72_1863 = (FStar_All.pipe_right args (FStar_List.partition (fun _72_1845 -> (match (_72_1845) with
| (arg, _72_1844) -> begin
(match ((let _173_667 = (unparen arg)
in _173_667.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.App ({FStar_Parser_AST.tm = FStar_Parser_AST.Var (d); FStar_Parser_AST.range = _72_1849; FStar_Parser_AST.level = _72_1847}, _72_1854, _72_1856) -> begin
(d.FStar_Ident.ident.FStar_Ident.idText = "decreases")
end
| _72_1860 -> begin
false
end)
end))))
in (match (_72_1863) with
| (decreases_clause, args) -> begin
(

let args = (match (args) with
| [] -> begin
(Prims.raise (FStar_Errors.Error ((("Not enough arguments to \'Lemma\'"), (t.FStar_Parser_AST.range)))))
end
| (ens)::[] -> begin
(

let req_true = (((FStar_Parser_AST.mk_term (FStar_Parser_AST.Requires ((((FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.true_lid)) t.FStar_Parser_AST.range FStar_Parser_AST.Formula)), (None)))) t.FStar_Parser_AST.range FStar_Parser_AST.Type_level)), (FStar_Parser_AST.Nothing))
in (unit)::(req_true)::(ens)::(nil_pat)::[])
end
| (req)::(ens)::[] -> begin
(unit)::(req)::(ens)::(nil_pat)::[]
end
| more -> begin
(unit)::more
end)
in (

let t = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Construct (((lemma), ((FStar_List.append args decreases_clause))))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
in (desugar_typ env t)))
end))))
end
| FStar_Parser_AST.Name (tot) when (((tot.FStar_Ident.ident.FStar_Ident.idText = "Tot") && (not ((FStar_Parser_DesugarEnv.is_effect_name env FStar_Absyn_Const.effect_Tot_lid)))) && (let _173_668 = (FStar_Parser_DesugarEnv.current_module env)
in (FStar_Ident.lid_equals _173_668 FStar_Absyn_Const.prims_lid))) -> begin
(

let args = (FStar_List.map (fun _72_1878 -> (match (_72_1878) with
| (t, imp) -> begin
(let _173_670 = (desugar_typ_or_exp env t)
in (FStar_All.pipe_left (arg_withimp_t imp) _173_670))
end)) args)
in (let _173_671 = (FStar_Absyn_Util.ftv FStar_Absyn_Const.effect_Tot_lid FStar_Absyn_Syntax.kun)
in (FStar_Absyn_Util.mk_typ_app _173_671 args)))
end
| _72_1881 -> begin
(desugar_typ env t)
end)
end)))
in (

let t = (pre_process_comp_typ t)
in (

let _72_1885 = (FStar_Absyn_Util.head_and_args t)
in (match (_72_1885) with
| (head, args) -> begin
(match ((let _173_673 = (let _173_672 = (FStar_Absyn_Util.compress_typ head)
in _173_672.FStar_Absyn_Syntax.n)
in ((_173_673), (args)))) with
| (FStar_Absyn_Syntax.Typ_const (eff), ((FStar_Util.Inl (result_typ), _72_1892))::rest) -> begin
(

let _72_1932 = (FStar_All.pipe_right rest (FStar_List.partition (fun uu___418 -> (match (uu___418) with
| (FStar_Util.Inr (_72_1898), _72_1901) -> begin
false
end
| (FStar_Util.Inl (t), _72_1906) -> begin
(match (t.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_app ({FStar_Absyn_Syntax.n = FStar_Absyn_Syntax.Typ_const (fv); FStar_Absyn_Syntax.tk = _72_1915; FStar_Absyn_Syntax.pos = _72_1913; FStar_Absyn_Syntax.fvs = _72_1911; FStar_Absyn_Syntax.uvs = _72_1909}, ((FStar_Util.Inr (_72_1920), _72_1923))::[]) -> begin
(FStar_Ident.lid_equals fv.FStar_Absyn_Syntax.v FStar_Absyn_Const.decreases_lid)
end
| _72_1929 -> begin
false
end)
end))))
in (match (_72_1932) with
| (dec, rest) -> begin
(

let decreases_clause = (FStar_All.pipe_right dec (FStar_List.map (fun uu___419 -> (match (uu___419) with
| (FStar_Util.Inl (t), _72_1937) -> begin
(match (t.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_app (_72_1940, ((FStar_Util.Inr (arg), _72_1944))::[]) -> begin
FStar_Absyn_Syntax.DECREASES (arg)
end
| _72_1950 -> begin
(failwith "impos")
end)
end
| _72_1952 -> begin
(failwith "impos")
end))))
in if ((FStar_Parser_DesugarEnv.is_effect_name env eff.FStar_Absyn_Syntax.v) || (FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_Tot_lid)) then begin
if ((FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_Tot_lid) && ((FStar_List.length decreases_clause) = (Prims.parse_int "0"))) then begin
(FStar_Absyn_Syntax.mk_Total result_typ)
end else begin
(

let flags = if (FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_Lemma_lid) then begin
(FStar_Absyn_Syntax.LEMMA)::[]
end else begin
if (FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_Tot_lid) then begin
(FStar_Absyn_Syntax.TOTAL)::[]
end else begin
if (FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_ML_lid) then begin
(FStar_Absyn_Syntax.MLEFFECT)::[]
end else begin
[]
end
end
end
in (

let rest = if (FStar_Ident.lid_equals eff.FStar_Absyn_Syntax.v FStar_Absyn_Const.effect_Lemma_lid) then begin
(match (rest) with
| (req)::(ens)::((FStar_Util.Inr (pat), aq))::[] -> begin
(let _173_680 = (let _173_679 = (let _173_678 = (let _173_677 = (let _173_676 = (FStar_Absyn_Syntax.mk_Exp_meta (FStar_Absyn_Syntax.Meta_desugared (((pat), (FStar_Absyn_Syntax.Meta_smt_pat)))))
in FStar_Util.Inr (_173_676))
in ((_173_677), (aq)))
in (_173_678)::[])
in (ens)::_173_679)
in (req)::_173_680)
end
| _72_1963 -> begin
rest
end)
end else begin
rest
end
in (FStar_Absyn_Syntax.mk_Comp {FStar_Absyn_Syntax.effect_name = eff.FStar_Absyn_Syntax.v; FStar_Absyn_Syntax.result_typ = result_typ; FStar_Absyn_Syntax.effect_args = rest; FStar_Absyn_Syntax.flags = (FStar_List.append flags decreases_clause)})))
end
end else begin
if default_ok then begin
(env.FStar_Parser_DesugarEnv.default_result_effect t r)
end else begin
(let _173_682 = (let _173_681 = (FStar_Absyn_Print.typ_to_string t)
in (FStar_Util.format1 "%s is not an effect" _173_681))
in (fail _173_682))
end
end)
end))
end
| _72_1966 -> begin
if default_ok then begin
(env.FStar_Parser_DesugarEnv.default_result_effect t r)
end else begin
(let _173_684 = (let _173_683 = (FStar_Absyn_Print.typ_to_string t)
in (FStar_Util.format1 "%s is not an effect" _173_683))
in (fail _173_684))
end
end)
end))))))
and desugar_kind : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.knd = (fun env k -> (

let pos = (fun f -> (f k.FStar_Parser_AST.range))
in (

let setpos = (fun kk -> (

let _72_1973 = kk
in {FStar_Absyn_Syntax.n = _72_1973.FStar_Absyn_Syntax.n; FStar_Absyn_Syntax.tk = _72_1973.FStar_Absyn_Syntax.tk; FStar_Absyn_Syntax.pos = k.FStar_Parser_AST.range; FStar_Absyn_Syntax.fvs = _72_1973.FStar_Absyn_Syntax.fvs; FStar_Absyn_Syntax.uvs = _72_1973.FStar_Absyn_Syntax.uvs}))
in (

let k = (unparen k)
in (match (k.FStar_Parser_AST.tm) with
| FStar_Parser_AST.Name ({FStar_Ident.ns = _72_1982; FStar_Ident.ident = _72_1980; FStar_Ident.nsstr = _72_1978; FStar_Ident.str = "Type"}) -> begin
(setpos FStar_Absyn_Syntax.mk_Kind_type)
end
| FStar_Parser_AST.Name ({FStar_Ident.ns = _72_1991; FStar_Ident.ident = _72_1989; FStar_Ident.nsstr = _72_1987; FStar_Ident.str = "Effect"}) -> begin
(setpos FStar_Absyn_Syntax.mk_Kind_effect)
end
| FStar_Parser_AST.Name (l) -> begin
(match ((let _173_696 = (FStar_Parser_DesugarEnv.qualify_lid env l)
in (FStar_Parser_DesugarEnv.find_kind_abbrev env _173_696))) with
| Some (l) -> begin
(FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Kind_abbrev ((((l), ([]))), (FStar_Absyn_Syntax.mk_Kind_unknown))))
end
| _72_1999 -> begin
(FStar_Parser_AST.error "Unexpected term where kind was expected" k k.FStar_Parser_AST.range)
end)
end
| FStar_Parser_AST.Wild -> begin
(setpos FStar_Absyn_Syntax.kun)
end
| FStar_Parser_AST.Product (bs, k) -> begin
(

let _72_2007 = (uncurry bs k)
in (match (_72_2007) with
| (bs, k) -> begin
(

let rec aux = (fun env bs uu___420 -> (match (uu___420) with
| [] -> begin
(let _173_707 = (let _173_706 = (let _173_705 = (desugar_kind env k)
in (((FStar_List.rev bs)), (_173_705)))
in (FStar_Absyn_Syntax.mk_Kind_arrow _173_706))
in (FStar_All.pipe_left pos _173_707))
end
| (hd)::tl -> begin
(

let _72_2018 = (let _173_709 = (let _173_708 = (FStar_Parser_DesugarEnv.default_ml env)
in (desugar_binder _173_708 hd))
in (FStar_All.pipe_right _173_709 (as_binder env hd.FStar_Parser_AST.aqual)))
in (match (_72_2018) with
| (b, env) -> begin
(aux env ((b)::bs) tl)
end))
end))
in (aux env [] bs))
end))
end
| FStar_Parser_AST.Construct (l, args) -> begin
(match ((FStar_Parser_DesugarEnv.find_kind_abbrev env l)) with
| None -> begin
(FStar_Parser_AST.error "Unexpected term where kind was expected" k k.FStar_Parser_AST.range)
end
| Some (l) -> begin
(

let args = (FStar_List.map (fun _72_2028 -> (match (_72_2028) with
| (t, b) -> begin
(

let qual = if (b = FStar_Parser_AST.Hash) then begin
Some (imp_tag)
end else begin
None
end
in (let _173_711 = (desugar_typ_or_exp env t)
in ((_173_711), (qual))))
end)) args)
in (FStar_All.pipe_left pos (FStar_Absyn_Syntax.mk_Kind_abbrev ((((l), (args))), (FStar_Absyn_Syntax.mk_Kind_unknown)))))
end)
end
| _72_2032 -> begin
(FStar_Parser_AST.error "Unexpected term where kind was expected" k k.FStar_Parser_AST.range)
end)))))
and desugar_formula' : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.typ = (fun env f -> (

let connective = (fun s -> (match (s) with
| "/\\" -> begin
Some (FStar_Absyn_Const.and_lid)
end
| "\\/" -> begin
Some (FStar_Absyn_Const.or_lid)
end
| "==>" -> begin
Some (FStar_Absyn_Const.imp_lid)
end
| "<==>" -> begin
Some (FStar_Absyn_Const.iff_lid)
end
| "~" -> begin
Some (FStar_Absyn_Const.not_lid)
end
| _72_2043 -> begin
None
end))
in (

let pos = (fun t -> (t None f.FStar_Parser_AST.range))
in (

let setpos = (fun t -> (

let _72_2048 = t
in {FStar_Absyn_Syntax.n = _72_2048.FStar_Absyn_Syntax.n; FStar_Absyn_Syntax.tk = _72_2048.FStar_Absyn_Syntax.tk; FStar_Absyn_Syntax.pos = f.FStar_Parser_AST.range; FStar_Absyn_Syntax.fvs = _72_2048.FStar_Absyn_Syntax.fvs; FStar_Absyn_Syntax.uvs = _72_2048.FStar_Absyn_Syntax.uvs}))
in (

let desugar_quant = (fun q qt b pats body -> (

let tk = (desugar_binder env (

let _72_2056 = b
in {FStar_Parser_AST.b = _72_2056.FStar_Parser_AST.b; FStar_Parser_AST.brange = _72_2056.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _72_2056.FStar_Parser_AST.aqual}))
in (

let desugar_pats = (fun env pats -> (FStar_List.map (fun es -> (FStar_All.pipe_right es (FStar_List.map (fun e -> (let _173_747 = (desugar_typ_or_exp env e)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _173_747)))))) pats))
in (match (tk) with
| FStar_Util.Inl (Some (a), k) -> begin
(

let _72_2071 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (match (_72_2071) with
| (env, a) -> begin
(

let pats = (desugar_pats env pats)
in (

let body = (desugar_formula env body)
in (

let body = (match (pats) with
| [] -> begin
body
end
| _72_2076 -> begin
(let _173_748 = (FStar_Absyn_Syntax.mk_Typ_meta (FStar_Absyn_Syntax.Meta_pattern (((body), (pats)))))
in (FStar_All.pipe_left setpos _173_748))
end)
in (

let body = (let _173_754 = (let _173_753 = (let _173_752 = (let _173_751 = (FStar_Absyn_Syntax.t_binder (FStar_Absyn_Util.bvd_to_bvar_s a k))
in (_173_751)::[])
in ((_173_752), (body)))
in (FStar_Absyn_Syntax.mk_Typ_lam _173_753))
in (FStar_All.pipe_left pos _173_754))
in (let _173_758 = (let _173_757 = (FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range qt b.FStar_Parser_AST.brange) FStar_Absyn_Syntax.kun)
in (let _173_756 = (let _173_755 = (FStar_Absyn_Syntax.targ body)
in (_173_755)::[])
in (FStar_Absyn_Util.mk_typ_app _173_757 _173_756)))
in (FStar_All.pipe_left setpos _173_758))))))
end))
end
| FStar_Util.Inr (Some (x), t) -> begin
(

let _72_2086 = (FStar_Parser_DesugarEnv.push_local_vbinding env x)
in (match (_72_2086) with
| (env, x) -> begin
(

let pats = (desugar_pats env pats)
in (

let body = (desugar_formula env body)
in (

let body = (match (pats) with
| [] -> begin
body
end
| _72_2091 -> begin
(FStar_Absyn_Syntax.mk_Typ_meta (FStar_Absyn_Syntax.Meta_pattern (((body), (pats)))))
end)
in (

let body = (let _173_764 = (let _173_763 = (let _173_762 = (let _173_761 = (FStar_Absyn_Syntax.v_binder (FStar_Absyn_Util.bvd_to_bvar_s x t))
in (_173_761)::[])
in ((_173_762), (body)))
in (FStar_Absyn_Syntax.mk_Typ_lam _173_763))
in (FStar_All.pipe_left pos _173_764))
in (let _173_768 = (let _173_767 = (FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange) FStar_Absyn_Syntax.kun)
in (let _173_766 = (let _173_765 = (FStar_Absyn_Syntax.targ body)
in (_173_765)::[])
in (FStar_Absyn_Util.mk_typ_app _173_767 _173_766)))
in (FStar_All.pipe_left setpos _173_768))))))
end))
end
| _72_2095 -> begin
(failwith "impossible")
end))))
in (

let push_quant = (fun q binders pats body -> (match (binders) with
| (b)::(b')::_rest -> begin
(

let rest = (b')::_rest
in (

let body = (let _173_783 = (q ((rest), (pats), (body)))
in (let _173_782 = (FStar_Range.union_ranges b'.FStar_Parser_AST.brange body.FStar_Parser_AST.range)
in (FStar_Parser_AST.mk_term _173_783 _173_782 FStar_Parser_AST.Formula)))
in (let _173_784 = (q (((b)::[]), ([]), (body)))
in (FStar_Parser_AST.mk_term _173_784 f.FStar_Parser_AST.range FStar_Parser_AST.Formula))))
end
| _72_2109 -> begin
(failwith "impossible")
end))
in (match ((let _173_785 = (unparen f)
in _173_785.FStar_Parser_AST.tm)) with
| FStar_Parser_AST.Labeled (f, l, p) -> begin
(

let f = (desugar_formula env f)
in (FStar_Absyn_Syntax.mk_Typ_meta (FStar_Absyn_Syntax.Meta_labeled (((f), (l), (FStar_Absyn_Syntax.dummyRange), (p))))))
end
| FStar_Parser_AST.Op ("==", (hd)::_args) -> begin
(

let args = (hd)::_args
in (

let args = (FStar_List.map (fun t -> (let _173_787 = (desugar_typ_or_exp env t)
in (FStar_All.pipe_left (arg_withimp_t FStar_Parser_AST.Nothing) _173_787))) args)
in (

let eq = if (is_type env hd) then begin
(FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range FStar_Absyn_Const.eqT_lid f.FStar_Parser_AST.range) FStar_Absyn_Syntax.kun)
end else begin
(FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range FStar_Absyn_Const.eq2_lid f.FStar_Parser_AST.range) FStar_Absyn_Syntax.kun)
end
in (FStar_Absyn_Util.mk_typ_app eq args))))
end
| FStar_Parser_AST.Op (s, args) -> begin
(match ((((connective s)), (args))) with
| (Some (conn), (_72_2135)::(_72_2133)::[]) -> begin
(let _173_791 = (FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range conn f.FStar_Parser_AST.range) FStar_Absyn_Syntax.kun)
in (let _173_790 = (FStar_List.map (fun x -> (let _173_789 = (desugar_formula env x)
in (FStar_All.pipe_left FStar_Absyn_Syntax.targ _173_789))) args)
in (FStar_Absyn_Util.mk_typ_app _173_791 _173_790)))
end
| _72_2140 -> begin
if (is_type env f) then begin
(desugar_typ env f)
end else begin
(let _173_792 = (desugar_exp env f)
in (FStar_All.pipe_right _173_792 FStar_Absyn_Util.b2t))
end
end)
end
| FStar_Parser_AST.If (f1, f2, f3) -> begin
(let _173_796 = (FStar_Absyn_Util.ftv (FStar_Ident.set_lid_range FStar_Absyn_Const.ite_lid f.FStar_Parser_AST.range) FStar_Absyn_Syntax.kun)
in (let _173_795 = (FStar_List.map (fun x -> (match ((desugar_typ_or_exp env x)) with
| FStar_Util.Inl (t) -> begin
(FStar_Absyn_Syntax.targ t)
end
| FStar_Util.Inr (v) -> begin
(let _173_794 = (FStar_Absyn_Util.b2t v)
in (FStar_All.pipe_left FStar_Absyn_Syntax.targ _173_794))
end)) ((f1)::(f2)::(f3)::[]))
in (FStar_Absyn_Util.mk_typ_app _173_796 _173_795)))
end
| (FStar_Parser_AST.QForall ([], _, _)) | (FStar_Parser_AST.QExists ([], _, _)) -> begin
(failwith "Impossible: Quantifier without binders")
end
| FStar_Parser_AST.QForall ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _173_798 = (push_quant (fun x -> FStar_Parser_AST.QForall (x)) binders pats body)
in (desugar_formula env _173_798)))
end
| FStar_Parser_AST.QExists ((_1)::(_2)::_3, pats, body) -> begin
(

let binders = (_1)::(_2)::_3
in (let _173_800 = (push_quant (fun x -> FStar_Parser_AST.QExists (x)) binders pats body)
in (desugar_formula env _173_800)))
end
| FStar_Parser_AST.QForall ((b)::[], pats, body) -> begin
(desugar_quant FStar_Absyn_Const.forall_lid FStar_Absyn_Const.allTyp_lid b pats body)
end
| FStar_Parser_AST.QExists ((b)::[], pats, body) -> begin
(desugar_quant FStar_Absyn_Const.exists_lid FStar_Absyn_Const.allTyp_lid b pats body)
end
| FStar_Parser_AST.Paren (f) -> begin
(desugar_formula env f)
end
| _72_2202 -> begin
if (is_type env f) then begin
(desugar_typ env f)
end else begin
(let _173_801 = (desugar_exp env f)
in (FStar_All.pipe_left FStar_Absyn_Util.b2t _173_801))
end
end)))))))
and desugar_formula : env_t  ->  FStar_Parser_AST.term  ->  FStar_Absyn_Syntax.typ = (fun env t -> (desugar_formula' (

let _72_2205 = env
in {FStar_Parser_DesugarEnv.curmodule = _72_2205.FStar_Parser_DesugarEnv.curmodule; FStar_Parser_DesugarEnv.modules = _72_2205.FStar_Parser_DesugarEnv.modules; FStar_Parser_DesugarEnv.open_namespaces = _72_2205.FStar_Parser_DesugarEnv.open_namespaces; FStar_Parser_DesugarEnv.modul_abbrevs = _72_2205.FStar_Parser_DesugarEnv.modul_abbrevs; FStar_Parser_DesugarEnv.sigaccum = _72_2205.FStar_Parser_DesugarEnv.sigaccum; FStar_Parser_DesugarEnv.localbindings = _72_2205.FStar_Parser_DesugarEnv.localbindings; FStar_Parser_DesugarEnv.recbindings = _72_2205.FStar_Parser_DesugarEnv.recbindings; FStar_Parser_DesugarEnv.phase = FStar_Parser_AST.Formula; FStar_Parser_DesugarEnv.sigmap = _72_2205.FStar_Parser_DesugarEnv.sigmap; FStar_Parser_DesugarEnv.default_result_effect = _72_2205.FStar_Parser_DesugarEnv.default_result_effect; FStar_Parser_DesugarEnv.iface = _72_2205.FStar_Parser_DesugarEnv.iface; FStar_Parser_DesugarEnv.admitted_iface = _72_2205.FStar_Parser_DesugarEnv.admitted_iface}) t))
and desugar_binder : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder  ->  ((FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.knd), (FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.typ)) FStar_Util.either = (fun env b -> if (is_type_binder env b) then begin
(let _173_806 = (desugar_type_binder env b)
in FStar_Util.Inl (_173_806))
end else begin
(let _173_807 = (desugar_exp_binder env b)
in FStar_Util.Inr (_173_807))
end)
and typars_of_binders : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_DesugarEnv.env * ((((FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, FStar_Absyn_Syntax.knd) FStar_Absyn_Syntax.withinfo_t, ((FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, FStar_Absyn_Syntax.typ) FStar_Absyn_Syntax.withinfo_t) FStar_Util.either * FStar_Absyn_Syntax.arg_qualifier Prims.option) Prims.list) = (fun env bs -> (

let _72_2238 = (FStar_List.fold_left (fun _72_2213 b -> (match (_72_2213) with
| (env, out) -> begin
(

let tk = (desugar_binder env (

let _72_2215 = b
in {FStar_Parser_AST.b = _72_2215.FStar_Parser_AST.b; FStar_Parser_AST.brange = _72_2215.FStar_Parser_AST.brange; FStar_Parser_AST.blevel = FStar_Parser_AST.Formula; FStar_Parser_AST.aqual = _72_2215.FStar_Parser_AST.aqual}))
in (match (tk) with
| FStar_Util.Inl (Some (a), k) -> begin
(

let _72_2225 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (match (_72_2225) with
| (env, a) -> begin
((env), ((((FStar_Util.Inl ((FStar_Absyn_Util.bvd_to_bvar_s a k))), ((trans_aqual b.FStar_Parser_AST.aqual))))::out))
end))
end
| FStar_Util.Inr (Some (x), t) -> begin
(

let _72_2233 = (FStar_Parser_DesugarEnv.push_local_vbinding env x)
in (match (_72_2233) with
| (env, x) -> begin
((env), ((((FStar_Util.Inr ((FStar_Absyn_Util.bvd_to_bvar_s x t))), ((trans_aqual b.FStar_Parser_AST.aqual))))::out))
end))
end
| _72_2235 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected binder"), (b.FStar_Parser_AST.brange)))))
end))
end)) ((env), ([])) bs)
in (match (_72_2238) with
| (env, tpars) -> begin
((env), ((FStar_List.rev tpars)))
end)))
and desugar_exp_binder : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder  ->  (FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.typ) = (fun env b -> (match (b.FStar_Parser_AST.b) with
| FStar_Parser_AST.Annotated (x, t) -> begin
(let _173_814 = (desugar_typ env t)
in ((Some (x)), (_173_814)))
end
| FStar_Parser_AST.TVariable (t) -> begin
(let _173_815 = (FStar_Parser_DesugarEnv.fail_or2 (FStar_Parser_DesugarEnv.try_lookup_typ_var env) t)
in ((None), (_173_815)))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _173_816 = (desugar_typ env t)
in ((None), (_173_816)))
end
| FStar_Parser_AST.Variable (x) -> begin
((Some (x)), (FStar_Absyn_Syntax.tun))
end
| _72_2252 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected domain of an arrow or sum (expected a type)"), (b.FStar_Parser_AST.brange)))))
end))
and desugar_type_binder : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder  ->  (FStar_Ident.ident Prims.option * FStar_Absyn_Syntax.knd) = (fun env b -> (

let fail = (fun _72_2256 -> (match (()) with
| () -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected domain of an arrow or sum (expected a kind)"), (b.FStar_Parser_AST.brange)))))
end))
in (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.Annotated (x, t)) | (FStar_Parser_AST.TAnnotated (x, t)) -> begin
(let _173_821 = (desugar_kind env t)
in ((Some (x)), (_173_821)))
end
| FStar_Parser_AST.NoName (t) -> begin
(let _173_822 = (desugar_kind env t)
in ((None), (_173_822)))
end
| FStar_Parser_AST.TVariable (x) -> begin
((Some (x)), ((

let _72_2267 = FStar_Absyn_Syntax.mk_Kind_type
in {FStar_Absyn_Syntax.n = _72_2267.FStar_Absyn_Syntax.n; FStar_Absyn_Syntax.tk = _72_2267.FStar_Absyn_Syntax.tk; FStar_Absyn_Syntax.pos = b.FStar_Parser_AST.brange; FStar_Absyn_Syntax.fvs = _72_2267.FStar_Absyn_Syntax.fvs; FStar_Absyn_Syntax.uvs = _72_2267.FStar_Absyn_Syntax.uvs})))
end
| _72_2270 -> begin
(fail ())
end)))


let gather_tc_binders : ((((FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t, ((FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t) FStar_Util.either * FStar_Absyn_Syntax.arg_qualifier Prims.option) Prims.list  ->  (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax  ->  ((((FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t, ((FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t) FStar_Util.either * FStar_Absyn_Syntax.arg_qualifier Prims.option) Prims.list = (fun tps k -> (

let rec aux = (fun bs k -> (match (k.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Kind_arrow (binders, k) -> begin
(aux (FStar_List.append bs binders) k)
end
| FStar_Absyn_Syntax.Kind_abbrev (_72_2281, k) -> begin
(aux bs k)
end
| _72_2286 -> begin
bs
end))
in (let _173_831 = (aux tps k)
in (FStar_All.pipe_right _173_831 FStar_Absyn_Util.name_binders))))


let mk_data_discriminators : FStar_Absyn_Syntax.qualifier Prims.list  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Ident.lid  ->  ((((FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t, ((FStar_Absyn_Syntax.exp', (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax FStar_Absyn_Syntax.bvdef, (FStar_Absyn_Syntax.typ', (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.syntax) FStar_Absyn_Syntax.withinfo_t) FStar_Util.either * FStar_Absyn_Syntax.arg_qualifier Prims.option) Prims.list  ->  (FStar_Absyn_Syntax.knd', Prims.unit) FStar_Absyn_Syntax.syntax  ->  FStar_Ident.lident Prims.list  ->  FStar_Absyn_Syntax.sigelt Prims.list = (fun quals env t tps k datas -> (

let quals = (fun q -> if ((FStar_All.pipe_left Prims.op_Negation env.FStar_Parser_DesugarEnv.iface) || env.FStar_Parser_DesugarEnv.admitted_iface) then begin
(FStar_List.append ((FStar_Absyn_Syntax.Assumption)::q) quals)
end else begin
(FStar_List.append q quals)
end)
in (

let binders = (gather_tc_binders tps k)
in (

let p = (FStar_Ident.range_of_lid t)
in (

let imp_binders = (FStar_All.pipe_right binders (FStar_List.map (fun _72_2300 -> (match (_72_2300) with
| (x, _72_2299) -> begin
((x), (Some (imp_tag)))
end))))
in (

let binders = (let _173_852 = (let _173_851 = (let _173_850 = (let _173_849 = (let _173_848 = (FStar_Absyn_Util.ftv t FStar_Absyn_Syntax.kun)
in (let _173_847 = (FStar_Absyn_Util.args_of_non_null_binders binders)
in ((_173_848), (_173_847))))
in (FStar_Absyn_Syntax.mk_Typ_app' _173_849 None p))
in (FStar_All.pipe_left FStar_Absyn_Syntax.null_v_binder _173_850))
in (_173_851)::[])
in (FStar_List.append imp_binders _173_852))
in (

let disc_type = (let _173_855 = (let _173_854 = (let _173_853 = (FStar_Absyn_Util.ftv FStar_Absyn_Const.bool_lid FStar_Absyn_Syntax.ktype)
in (FStar_Absyn_Util.total_comp _173_853 p))
in ((binders), (_173_854)))
in (FStar_Absyn_Syntax.mk_Typ_fun _173_855 None p))
in (FStar_All.pipe_right datas (FStar_List.map (fun d -> (

let disc_name = (FStar_Absyn_Util.mk_discriminator d)
in (let _173_858 = (let _173_857 = (quals ((FStar_Absyn_Syntax.Logic)::(FStar_Absyn_Syntax.Discriminator (d))::[]))
in ((disc_name), (disc_type), (_173_857), ((FStar_Ident.range_of_lid disc_name))))
in FStar_Absyn_Syntax.Sig_val_decl (_173_858)))))))))))))


let mk_indexed_projectors = (fun fvq refine_domain env _72_2312 lid formals t -> (match (_72_2312) with
| (tc, tps, k) -> begin
(

let binders = (gather_tc_binders tps k)
in (

let p = (FStar_Ident.range_of_lid lid)
in (

let pos = (fun q -> (FStar_Absyn_Syntax.withinfo q None p))
in (

let projectee = (let _173_869 = (FStar_Absyn_Syntax.mk_ident (("projectee"), (p)))
in (let _173_868 = (FStar_Absyn_Util.genident (Some (p)))
in {FStar_Absyn_Syntax.ppname = _173_869; FStar_Absyn_Syntax.realname = _173_868}))
in (

let arg_exp = (FStar_Absyn_Util.bvd_to_exp projectee FStar_Absyn_Syntax.tun)
in (

let arg_binder = (

let arg_typ = (let _173_872 = (let _173_871 = (FStar_Absyn_Util.ftv tc FStar_Absyn_Syntax.kun)
in (let _173_870 = (FStar_Absyn_Util.args_of_non_null_binders binders)
in ((_173_871), (_173_870))))
in (FStar_Absyn_Syntax.mk_Typ_app' _173_872 None p))
in if (not (refine_domain)) then begin
(FStar_Absyn_Syntax.v_binder (FStar_Absyn_Util.bvd_to_bvar_s projectee arg_typ))
end else begin
(

let disc_name = (FStar_Absyn_Util.mk_discriminator lid)
in (

let x = (FStar_Absyn_Util.gen_bvar arg_typ)
in (let _173_882 = (let _173_881 = (let _173_880 = (let _173_879 = (let _173_878 = (let _173_877 = (let _173_876 = (FStar_Absyn_Util.fvar None disc_name p)
in (let _173_875 = (let _173_874 = (let _173_873 = (FStar_Absyn_Util.bvar_to_exp x)
in (FStar_All.pipe_left FStar_Absyn_Syntax.varg _173_873))
in (_173_874)::[])
in ((_173_876), (_173_875))))
in (FStar_Absyn_Syntax.mk_Exp_app _173_877 None p))
in (FStar_Absyn_Util.b2t _173_878))
in ((x), (_173_879)))
in (FStar_Absyn_Syntax.mk_Typ_refine _173_880 None p))
in (FStar_All.pipe_left (FStar_Absyn_Util.bvd_to_bvar_s projectee) _173_881))
in (FStar_All.pipe_left FStar_Absyn_Syntax.v_binder _173_882))))
end)
in (

let imp_binders = (FStar_All.pipe_right binders (FStar_List.map (fun _72_2329 -> (match (_72_2329) with
| (x, _72_2328) -> begin
((x), (Some (imp_tag)))
end))))
in (

let binders = (FStar_List.append imp_binders ((arg_binder)::[]))
in (

let arg = (FStar_Absyn_Util.arg_of_non_null_binder arg_binder)
in (

let subst = (let _173_890 = (FStar_All.pipe_right formals (FStar_List.mapi (fun i f -> (match ((Prims.fst f)) with
| FStar_Util.Inl (a) -> begin
(

let _72_2340 = (FStar_Absyn_Util.mk_field_projector_name lid a i)
in (match (_72_2340) with
| (field_name, _72_2339) -> begin
(

let proj = (let _173_887 = (let _173_886 = (FStar_Absyn_Util.ftv field_name FStar_Absyn_Syntax.kun)
in ((_173_886), ((arg)::[])))
in (FStar_Absyn_Syntax.mk_Typ_app _173_887 None p))
in (FStar_Util.Inl (((a.FStar_Absyn_Syntax.v), (proj))))::[])
end))
end
| FStar_Util.Inr (x) -> begin
(

let _72_2347 = (FStar_Absyn_Util.mk_field_projector_name lid x i)
in (match (_72_2347) with
| (field_name, _72_2346) -> begin
(

let proj = (let _173_889 = (let _173_888 = (FStar_Absyn_Util.fvar None field_name p)
in ((_173_888), ((arg)::[])))
in (FStar_Absyn_Syntax.mk_Exp_app _173_889 None p))
in (FStar_Util.Inr (((x.FStar_Absyn_Syntax.v), (proj))))::[])
end))
end))))
in (FStar_All.pipe_right _173_890 FStar_List.flatten))
in (

let ntps = (FStar_List.length tps)
in (

let all_params = (let _173_892 = (FStar_All.pipe_right tps (FStar_List.map (fun _72_2354 -> (match (_72_2354) with
| (b, _72_2353) -> begin
((b), (Some (imp_tag)))
end))))
in (FStar_List.append _173_892 formals))
in (let _173_922 = (FStar_All.pipe_right formals (FStar_List.mapi (fun i ax -> (match ((Prims.fst ax)) with
| FStar_Util.Inl (a) -> begin
(

let _72_2363 = (FStar_Absyn_Util.mk_field_projector_name lid a i)
in (match (_72_2363) with
| (field_name, _72_2362) -> begin
(

let kk = (let _173_896 = (let _173_895 = (FStar_Absyn_Util.subst_kind subst a.FStar_Absyn_Syntax.sort)
in ((binders), (_173_895)))
in (FStar_Absyn_Syntax.mk_Kind_arrow _173_896 p))
in (FStar_Absyn_Syntax.Sig_tycon (((field_name), ([]), (kk), ([]), ([]), ((FStar_Absyn_Syntax.Logic)::(FStar_Absyn_Syntax.Projector (((lid), (FStar_Util.Inl (a.FStar_Absyn_Syntax.v)))))::[]), ((FStar_Ident.range_of_lid field_name)))))::[])
end))
end
| FStar_Util.Inr (x) -> begin
(

let _72_2370 = (FStar_Absyn_Util.mk_field_projector_name lid x i)
in (match (_72_2370) with
| (field_name, _72_2369) -> begin
(

let t = (let _173_899 = (let _173_898 = (let _173_897 = (FStar_Absyn_Util.subst_typ subst x.FStar_Absyn_Syntax.sort)
in (FStar_Absyn_Util.total_comp _173_897 p))
in ((binders), (_173_898)))
in (FStar_Absyn_Syntax.mk_Typ_fun _173_899 None p))
in (

let quals = (fun q -> if ((not (env.FStar_Parser_DesugarEnv.iface)) || env.FStar_Parser_DesugarEnv.admitted_iface) then begin
(FStar_Absyn_Syntax.Assumption)::q
end else begin
q
end)
in (

let quals = (quals ((FStar_Absyn_Syntax.Logic)::(FStar_Absyn_Syntax.Projector (((lid), (FStar_Util.Inr (x.FStar_Absyn_Syntax.v)))))::[]))
in (

let impl = if (((let _173_902 = (FStar_Parser_DesugarEnv.current_module env)
in (FStar_Ident.lid_equals FStar_Absyn_Const.prims_lid _173_902)) || (fvq <> FStar_Absyn_Syntax.Data_ctor)) || (let _173_904 = (let _173_903 = (FStar_Parser_DesugarEnv.current_module env)
in _173_903.FStar_Ident.str)
in (FStar_Options.dont_gen_projectors _173_904))) then begin
[]
end else begin
(

let projection = (FStar_Absyn_Util.gen_bvar FStar_Absyn_Syntax.tun)
in (

let as_imp = (fun uu___421 -> (match (uu___421) with
| Some (FStar_Absyn_Syntax.Implicit (_72_2378)) -> begin
true
end
| _72_2382 -> begin
false
end))
in (

let arg_pats = (let _173_919 = (FStar_All.pipe_right all_params (FStar_List.mapi (fun j by -> (match (by) with
| (FStar_Util.Inl (_72_2387), imp) -> begin
if (j < ntps) then begin
[]
end else begin
(let _173_912 = (let _173_911 = (let _173_910 = (let _173_909 = (FStar_Absyn_Util.gen_bvar FStar_Absyn_Syntax.kun)
in FStar_Absyn_Syntax.Pat_tvar (_173_909))
in (pos _173_910))
in ((_173_911), ((as_imp imp))))
in (_173_912)::[])
end
end
| (FStar_Util.Inr (_72_2392), imp) -> begin
if ((i + ntps) = j) then begin
(let _173_914 = (let _173_913 = (pos (FStar_Absyn_Syntax.Pat_var (projection)))
in ((_173_913), ((as_imp imp))))
in (_173_914)::[])
end else begin
if (j < ntps) then begin
[]
end else begin
(let _173_918 = (let _173_917 = (let _173_916 = (let _173_915 = (FStar_Absyn_Util.gen_bvar FStar_Absyn_Syntax.tun)
in FStar_Absyn_Syntax.Pat_wild (_173_915))
in (pos _173_916))
in ((_173_917), ((as_imp imp))))
in (_173_918)::[])
end
end
end))))
in (FStar_All.pipe_right _173_919 FStar_List.flatten))
in (

let pat = (let _173_921 = (FStar_All.pipe_right (FStar_Absyn_Syntax.Pat_cons ((((FStar_Absyn_Util.fv lid)), (Some (fvq)), (arg_pats)))) pos)
in (let _173_920 = (FStar_Absyn_Util.bvar_to_exp projection)
in ((_173_921), (None), (_173_920))))
in (

let body = (FStar_Absyn_Syntax.mk_Exp_match ((arg_exp), ((pat)::[])) None p)
in (

let imp = (FStar_Absyn_Syntax.mk_Exp_abs ((binders), (body)) None (FStar_Ident.range_of_lid field_name))
in (

let lb = {FStar_Absyn_Syntax.lbname = FStar_Util.Inr (field_name); FStar_Absyn_Syntax.lbtyp = FStar_Absyn_Syntax.tun; FStar_Absyn_Syntax.lbeff = FStar_Absyn_Const.effect_Tot_lid; FStar_Absyn_Syntax.lbdef = imp}
in (FStar_Absyn_Syntax.Sig_let (((((false), ((lb)::[]))), (p), ([]), (quals))))::[])))))))
end
in (FStar_Absyn_Syntax.Sig_val_decl (((field_name), (t), (quals), ((FStar_Ident.range_of_lid field_name)))))::impl))))
end))
end))))
in (FStar_All.pipe_right _173_922 FStar_List.flatten))))))))))))))
end))


let mk_data_projectors : FStar_Parser_DesugarEnv.env  ->  FStar_Absyn_Syntax.sigelt  ->  FStar_Absyn_Syntax.sigelt Prims.list = (fun env uu___424 -> (match (uu___424) with
| FStar_Absyn_Syntax.Sig_datacon (lid, t, tycon, quals, _72_2409, _72_2411) when (not ((FStar_Ident.lid_equals lid FStar_Absyn_Const.lexcons_lid))) -> begin
(

let refine_domain = if (FStar_All.pipe_right quals (FStar_Util.for_some (fun uu___422 -> (match (uu___422) with
| FStar_Absyn_Syntax.RecordConstructor (_72_2416) -> begin
true
end
| _72_2419 -> begin
false
end)))) then begin
false
end else begin
(

let _72_2425 = tycon
in (match (_72_2425) with
| (l, _72_2422, _72_2424) -> begin
(match ((FStar_Parser_DesugarEnv.find_all_datacons env l)) with
| Some (l) -> begin
((FStar_List.length l) > (Prims.parse_int "1"))
end
| _72_2429 -> begin
true
end)
end))
end
in (match ((FStar_Absyn_Util.function_formals t)) with
| Some (formals, cod) -> begin
(

let cod = (FStar_Absyn_Util.comp_result cod)
in (

let qual = (match ((FStar_Util.find_map quals (fun uu___423 -> (match (uu___423) with
| FStar_Absyn_Syntax.RecordConstructor (fns) -> begin
Some (FStar_Absyn_Syntax.Record_ctor (((lid), (fns))))
end
| _72_2440 -> begin
None
end)))) with
| None -> begin
FStar_Absyn_Syntax.Data_ctor
end
| Some (q) -> begin
q
end)
in (mk_indexed_projectors qual refine_domain env tycon lid formals cod)))
end
| _72_2446 -> begin
[]
end))
end
| _72_2448 -> begin
[]
end))


let rec desugar_tycon : FStar_Parser_DesugarEnv.env  ->  FStar_Range.range  ->  FStar_Absyn_Syntax.qualifier Prims.list  ->  FStar_Parser_AST.tycon Prims.list  ->  (env_t * FStar_Absyn_Syntax.sigelts) = (fun env rng quals tcs -> (

let tycon_id = (fun uu___425 -> (match (uu___425) with
| (FStar_Parser_AST.TyconAbstract (id, _, _)) | (FStar_Parser_AST.TyconAbbrev (id, _, _, _)) | (FStar_Parser_AST.TyconRecord (id, _, _, _)) | (FStar_Parser_AST.TyconVariant (id, _, _, _)) -> begin
id
end))
in (

let binder_to_term = (fun b -> (match (b.FStar_Parser_AST.b) with
| (FStar_Parser_AST.Annotated (x, _)) | (FStar_Parser_AST.Variable (x)) -> begin
(let _173_942 = (let _173_941 = (FStar_Ident.lid_of_ids ((x)::[]))
in FStar_Parser_AST.Var (_173_941))
in (FStar_Parser_AST.mk_term _173_942 x.FStar_Ident.idRange FStar_Parser_AST.Expr))
end
| (FStar_Parser_AST.TAnnotated (a, _)) | (FStar_Parser_AST.TVariable (a)) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar (a)) a.FStar_Ident.idRange FStar_Parser_AST.Type_level)
end
| FStar_Parser_AST.NoName (t) -> begin
t
end))
in (

let tot = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Name (FStar_Absyn_Const.effect_Tot_lid)) rng FStar_Parser_AST.Expr)
in (

let with_constructor_effect = (fun t -> (FStar_Parser_AST.mk_term (FStar_Parser_AST.App (((tot), (t), (FStar_Parser_AST.Nothing)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level))
in (

let apply_binders = (fun t binders -> (

let imp_of_aqual = (fun b -> (match (b.FStar_Parser_AST.aqual) with
| Some (FStar_Parser_AST.Implicit) -> begin
FStar_Parser_AST.Hash
end
| _72_2513 -> begin
FStar_Parser_AST.Nothing
end))
in (FStar_List.fold_left (fun out b -> (let _173_955 = (let _173_954 = (let _173_953 = (binder_to_term b)
in ((out), (_173_953), ((imp_of_aqual b))))
in FStar_Parser_AST.App (_173_954))
in (FStar_Parser_AST.mk_term _173_955 out.FStar_Parser_AST.range out.FStar_Parser_AST.level))) t binders)))
in (

let tycon_record_as_variant = (fun uu___426 -> (match (uu___426) with
| FStar_Parser_AST.TyconRecord (id, parms, kopt, fields) -> begin
(

let constrName = (FStar_Ident.mk_ident (((Prims.strcat "Mk" id.FStar_Ident.idText)), (id.FStar_Ident.idRange)))
in (

let mfields = (FStar_List.map (fun _72_2528 -> (match (_72_2528) with
| (x, t, _72_2527) -> begin
(FStar_Parser_AST.mk_binder (FStar_Parser_AST.Annotated ((((FStar_Absyn_Util.mangle_field_name x)), (t)))) x.FStar_Ident.idRange FStar_Parser_AST.Expr None)
end)) fields)
in (

let result = (let _173_961 = (let _173_960 = (let _173_959 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_173_959))
in (FStar_Parser_AST.mk_term _173_960 id.FStar_Ident.idRange FStar_Parser_AST.Type_level))
in (apply_binders _173_961 parms))
in (

let constrTyp = (FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((mfields), ((with_constructor_effect result))))) id.FStar_Ident.idRange FStar_Parser_AST.Type_level)
in (let _173_963 = (FStar_All.pipe_right fields (FStar_List.map (fun _72_2537 -> (match (_72_2537) with
| (x, _72_2534, _72_2536) -> begin
(FStar_Parser_DesugarEnv.qualify env x)
end))))
in ((FStar_Parser_AST.TyconVariant (((id), (parms), (kopt), ((((constrName), (Some (constrTyp)), (None), (false)))::[])))), (_173_963)))))))
end
| _72_2539 -> begin
(failwith "impossible")
end))
in (

let desugar_abstract_tc = (fun quals _env mutuals uu___427 -> (match (uu___427) with
| FStar_Parser_AST.TyconAbstract (id, binders, kopt) -> begin
(

let _72_2553 = (typars_of_binders _env binders)
in (match (_72_2553) with
| (_env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
FStar_Absyn_Syntax.kun
end
| Some (k) -> begin
(desugar_kind _env' k)
end)
in (

let tconstr = (let _173_974 = (let _173_973 = (let _173_972 = (FStar_Ident.lid_of_ids ((id)::[]))
in FStar_Parser_AST.Var (_173_972))
in (FStar_Parser_AST.mk_term _173_973 id.FStar_Ident.idRange FStar_Parser_AST.Type_level))
in (apply_binders _173_974 binders))
in (

let qlid = (FStar_Parser_DesugarEnv.qualify _env id)
in (

let se = FStar_Absyn_Syntax.Sig_tycon (((qlid), (typars), (k), (mutuals), ([]), (quals), (rng)))
in (

let _env = (FStar_Parser_DesugarEnv.push_rec_binding _env (FStar_Parser_DesugarEnv.Binding_tycon (qlid)))
in (

let _env2 = (FStar_Parser_DesugarEnv.push_rec_binding _env' (FStar_Parser_DesugarEnv.Binding_tycon (qlid)))
in ((_env), (_env2), (se), (tconstr))))))))
end))
end
| _72_2564 -> begin
(failwith "Unexpected tycon")
end))
in (

let push_tparam = (fun env uu___428 -> (match (uu___428) with
| (FStar_Util.Inr (x), _72_2571) -> begin
(FStar_Parser_DesugarEnv.push_bvvdef env x.FStar_Absyn_Syntax.v)
end
| (FStar_Util.Inl (a), _72_2576) -> begin
(FStar_Parser_DesugarEnv.push_btvdef env a.FStar_Absyn_Syntax.v)
end))
in (

let push_tparams = (FStar_List.fold_left push_tparam)
in (match (tcs) with
| (FStar_Parser_AST.TyconAbstract (_72_2580))::[] -> begin
(

let tc = (FStar_List.hd tcs)
in (

let _72_2591 = (desugar_abstract_tc quals env [] tc)
in (match (_72_2591) with
| (_72_2585, _72_2587, se, _72_2590) -> begin
(

let quals = if ((FStar_All.pipe_right quals (FStar_List.contains FStar_Absyn_Syntax.Assumption)) || (FStar_All.pipe_right quals (FStar_List.contains FStar_Absyn_Syntax.New))) then begin
quals
end else begin
(

let _72_2592 = (let _173_984 = (FStar_Range.string_of_range rng)
in (let _173_983 = (let _173_982 = (let _173_981 = (FStar_Absyn_Util.lids_of_sigelt se)
in (FStar_All.pipe_right _173_981 (FStar_List.map FStar_Absyn_Print.sli)))
in (FStar_All.pipe_right _173_982 (FStar_String.concat ", ")))
in (FStar_Util.print2 "%s (Warning): Adding an implicit \'new\' qualifier on %s\n" _173_984 _173_983)))
in (FStar_Absyn_Syntax.New)::quals)
end
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se)
in ((env), ((se)::[]))))
end)))
end
| (FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t))::[] -> begin
(

let _72_2605 = (typars_of_binders env binders)
in (match (_72_2605) with
| (env', typars) -> begin
(

let k = (match (kopt) with
| None -> begin
if (FStar_Util.for_some (fun uu___429 -> (match (uu___429) with
| FStar_Absyn_Syntax.Effect -> begin
true
end
| _72_2610 -> begin
false
end)) quals) then begin
FStar_Absyn_Syntax.mk_Kind_effect
end else begin
FStar_Absyn_Syntax.kun
end
end
| Some (k) -> begin
(desugar_kind env' k)
end)
in (

let t0 = t
in (

let quals = if (FStar_All.pipe_right quals (FStar_Util.for_some (fun uu___430 -> (match (uu___430) with
| FStar_Absyn_Syntax.Logic -> begin
true
end
| _72_2618 -> begin
false
end)))) then begin
quals
end else begin
if (t0.FStar_Parser_AST.level = FStar_Parser_AST.Formula) then begin
(FStar_Absyn_Syntax.Logic)::quals
end else begin
quals
end
end
in (

let se = if (FStar_All.pipe_right quals (FStar_List.contains FStar_Absyn_Syntax.Effect)) then begin
(

let c = (desugar_comp t.FStar_Parser_AST.range false env' t)
in (let _173_990 = (let _173_989 = (FStar_Parser_DesugarEnv.qualify env id)
in (let _173_988 = (FStar_All.pipe_right quals (FStar_List.filter (fun uu___431 -> (match (uu___431) with
| FStar_Absyn_Syntax.Effect -> begin
false
end
| _72_2624 -> begin
true
end))))
in ((_173_989), (typars), (c), (_173_988), (rng))))
in FStar_Absyn_Syntax.Sig_effect_abbrev (_173_990)))
end else begin
(

let t = (desugar_typ env' t)
in (let _173_992 = (let _173_991 = (FStar_Parser_DesugarEnv.qualify env id)
in ((_173_991), (typars), (k), (t), (quals), (rng)))
in FStar_Absyn_Syntax.Sig_typ_abbrev (_173_992)))
end
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se)
in ((env), ((se)::[])))))))
end))
end
| (FStar_Parser_AST.TyconRecord (_72_2629))::[] -> begin
(

let trec = (FStar_List.hd tcs)
in (

let _72_2635 = (tycon_record_as_variant trec)
in (match (_72_2635) with
| (t, fs) -> begin
(desugar_tycon env rng ((FStar_Absyn_Syntax.RecordType (fs))::quals) ((t)::[]))
end)))
end
| (_72_2639)::_72_2637 -> begin
(

let env0 = env
in (

let mutuals = (FStar_List.map (fun x -> (FStar_All.pipe_left (FStar_Parser_DesugarEnv.qualify env) (tycon_id x))) tcs)
in (

let rec collect_tcs = (fun quals et tc -> (

let _72_2650 = et
in (match (_72_2650) with
| (env, tcs) -> begin
(match (tc) with
| FStar_Parser_AST.TyconRecord (_72_2652) -> begin
(

let trec = tc
in (

let _72_2657 = (tycon_record_as_variant trec)
in (match (_72_2657) with
| (t, fs) -> begin
(collect_tcs ((FStar_Absyn_Syntax.RecordType (fs))::quals) ((env), (tcs)) t)
end)))
end
| FStar_Parser_AST.TyconVariant (id, binders, kopt, constructors) -> begin
(

let _72_2669 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (_72_2669) with
| (env, _72_2666, se, tconstr) -> begin
((env), ((FStar_Util.Inl (((se), (constructors), (tconstr), (quals))))::tcs))
end))
end
| FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t) -> begin
(

let _72_2681 = (desugar_abstract_tc quals env mutuals (FStar_Parser_AST.TyconAbstract (((id), (binders), (kopt)))))
in (match (_72_2681) with
| (env, _72_2678, se, tconstr) -> begin
((env), ((FStar_Util.Inr (((se), (t), (quals))))::tcs))
end))
end
| _72_2683 -> begin
(failwith "Unrecognized mutual type definition")
end)
end)))
in (

let _72_2686 = (FStar_List.fold_left (collect_tcs quals) ((env), ([])) tcs)
in (match (_72_2686) with
| (env, tcs) -> begin
(

let tcs = (FStar_List.rev tcs)
in (

let sigelts = (FStar_All.pipe_right tcs (FStar_List.collect (fun uu___433 -> (match (uu___433) with
| FStar_Util.Inr (FStar_Absyn_Syntax.Sig_tycon (id, tpars, k, _72_2693, _72_2695, _72_2697, _72_2699), t, quals) -> begin
(

let env_tps = (push_tparams env tpars)
in (

let t = (desugar_typ env_tps t)
in (FStar_Absyn_Syntax.Sig_typ_abbrev (((id), (tpars), (k), (t), ([]), (rng))))::[]))
end
| FStar_Util.Inl (FStar_Absyn_Syntax.Sig_tycon (tname, tpars, k, mutuals, _72_2713, tags, _72_2716), constrs, tconstr, quals) -> begin
(

let tycon = ((tname), (tpars), (k))
in (

let env_tps = (push_tparams env tpars)
in (

let _72_2749 = (let _173_1008 = (FStar_All.pipe_right constrs (FStar_List.map (fun _72_2731 -> (match (_72_2731) with
| (id, topt, _72_2729, of_notation) -> begin
(

let t = if of_notation then begin
(match (topt) with
| Some (t) -> begin
(FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (((((FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName (t)) t.FStar_Parser_AST.range t.FStar_Parser_AST.level None))::[]), (tconstr)))) t.FStar_Parser_AST.range t.FStar_Parser_AST.level)
end
| None -> begin
tconstr
end)
end else begin
(match (topt) with
| None -> begin
(failwith "Impossible")
end
| Some (t) -> begin
t
end)
end
in (

let t = (let _173_1003 = (FStar_Parser_DesugarEnv.default_total env_tps)
in (let _173_1002 = (close env_tps t)
in (desugar_typ _173_1003 _173_1002)))
in (

let name = (FStar_Parser_DesugarEnv.qualify env id)
in (

let quals = (FStar_All.pipe_right tags (FStar_List.collect (fun uu___432 -> (match (uu___432) with
| FStar_Absyn_Syntax.RecordType (fns) -> begin
(FStar_Absyn_Syntax.RecordConstructor (fns))::[]
end
| _72_2745 -> begin
[]
end))))
in (let _173_1007 = (let _173_1006 = (let _173_1005 = (FStar_All.pipe_right t FStar_Absyn_Util.name_function_binders)
in ((name), (_173_1005), (tycon), (quals), (mutuals), (rng)))
in FStar_Absyn_Syntax.Sig_datacon (_173_1006))
in ((name), (_173_1007)))))))
end))))
in (FStar_All.pipe_left FStar_List.split _173_1008))
in (match (_72_2749) with
| (constrNames, constrs) -> begin
(FStar_Absyn_Syntax.Sig_tycon (((tname), (tpars), (k), (mutuals), (constrNames), (tags), (rng))))::constrs
end))))
end
| _72_2751 -> begin
(failwith "impossible")
end))))
in (

let bundle = (let _173_1010 = (let _173_1009 = (FStar_List.collect FStar_Absyn_Util.lids_of_sigelt sigelts)
in ((sigelts), (quals), (_173_1009), (rng)))
in FStar_Absyn_Syntax.Sig_bundle (_173_1010))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env0 bundle)
in (

let data_ops = (FStar_All.pipe_right sigelts (FStar_List.collect (mk_data_projectors env)))
in (

let discs = (FStar_All.pipe_right sigelts (FStar_List.collect (fun uu___434 -> (match (uu___434) with
| FStar_Absyn_Syntax.Sig_tycon (tname, tps, k, _72_2761, constrs, quals, _72_2765) -> begin
(mk_data_discriminators quals env tname tps k constrs)
end
| _72_2769 -> begin
[]
end))))
in (

let ops = (FStar_List.append discs data_ops)
in (

let env = (FStar_List.fold_left FStar_Parser_DesugarEnv.push_sigelt env ops)
in ((env), ((FStar_List.append ((bundle)::[]) ops)))))))))))
end)))))
end
| [] -> begin
(failwith "impossible")
end)))))))))))


let desugar_binders : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.binder Prims.list  ->  (FStar_Parser_DesugarEnv.env * FStar_Absyn_Syntax.binder Prims.list) = (fun env binders -> (

let _72_2800 = (FStar_List.fold_left (fun _72_2778 b -> (match (_72_2778) with
| (env, binders) -> begin
(match ((desugar_binder env b)) with
| FStar_Util.Inl (Some (a), k) -> begin
(

let _72_2787 = (FStar_Parser_DesugarEnv.push_local_tbinding env a)
in (match (_72_2787) with
| (env, a) -> begin
(let _173_1019 = (let _173_1018 = (FStar_Absyn_Syntax.t_binder (FStar_Absyn_Util.bvd_to_bvar_s a k))
in (_173_1018)::binders)
in ((env), (_173_1019)))
end))
end
| FStar_Util.Inr (Some (x), t) -> begin
(

let _72_2795 = (FStar_Parser_DesugarEnv.push_local_vbinding env x)
in (match (_72_2795) with
| (env, x) -> begin
(let _173_1021 = (let _173_1020 = (FStar_Absyn_Syntax.v_binder (FStar_Absyn_Util.bvd_to_bvar_s x t))
in (_173_1020)::binders)
in ((env), (_173_1021)))
end))
end
| _72_2797 -> begin
(Prims.raise (FStar_Errors.Error ((("Missing name in binder"), (b.FStar_Parser_AST.brange)))))
end)
end)) ((env), ([])) binders)
in (match (_72_2800) with
| (env, binders) -> begin
((env), ((FStar_List.rev binders)))
end)))


let trans_qual : FStar_Range.range  ->  FStar_Parser_AST.qualifier  ->  FStar_Absyn_Syntax.qualifier = (fun r uu___435 -> (match (uu___435) with
| FStar_Parser_AST.Private -> begin
FStar_Absyn_Syntax.Private
end
| FStar_Parser_AST.Assumption -> begin
FStar_Absyn_Syntax.Assumption
end
| FStar_Parser_AST.Opaque -> begin
FStar_Absyn_Syntax.Opaque
end
| FStar_Parser_AST.Logic -> begin
FStar_Absyn_Syntax.Logic
end
| FStar_Parser_AST.Abstract -> begin
FStar_Absyn_Syntax.Abstract
end
| FStar_Parser_AST.New -> begin
FStar_Absyn_Syntax.New
end
| FStar_Parser_AST.TotalEffect -> begin
FStar_Absyn_Syntax.TotalEffect
end
| FStar_Parser_AST.DefaultEffect -> begin
FStar_Absyn_Syntax.DefaultEffect (None)
end
| FStar_Parser_AST.Effect_qual -> begin
FStar_Absyn_Syntax.Effect
end
| (FStar_Parser_AST.Reflectable) | (FStar_Parser_AST.Reifiable) | (FStar_Parser_AST.Inline) | (FStar_Parser_AST.Irreducible) | (FStar_Parser_AST.Noeq) | (FStar_Parser_AST.Unopteq) | (FStar_Parser_AST.Visible) | (FStar_Parser_AST.Unfold_for_unification_and_vcgen) | (FStar_Parser_AST.NoExtract) -> begin
(Prims.raise (FStar_Errors.Error ((("The noextract qualifier is supported only with the --universes option"), (r)))))
end
| FStar_Parser_AST.Inline_for_extraction -> begin
(Prims.raise (FStar_Errors.Error ((("This qualifier is supported only with the --universes option"), (r)))))
end))


let trans_pragma : FStar_Parser_AST.pragma  ->  FStar_Absyn_Syntax.pragma = (fun uu___436 -> (match (uu___436) with
| FStar_Parser_AST.SetOptions (s) -> begin
FStar_Absyn_Syntax.SetOptions (s)
end
| FStar_Parser_AST.ResetOptions (s) -> begin
FStar_Absyn_Syntax.ResetOptions (s)
end))


let trans_quals : FStar_Range.range  ->  FStar_Parser_AST.qualifier Prims.list  ->  FStar_Absyn_Syntax.qualifier Prims.list = (fun r -> (FStar_List.map (trans_qual r)))


let rec desugar_decl : env_t  ->  FStar_Parser_AST.decl  ->  (env_t * FStar_Absyn_Syntax.sigelts) = (fun env d -> (

let trans_quals = (trans_quals d.FStar_Parser_AST.drange)
in (match (d.FStar_Parser_AST.d) with
| FStar_Parser_AST.Fsdoc (_72_2832) -> begin
((env), ([]))
end
| FStar_Parser_AST.Pragma (p) -> begin
(

let se = FStar_Absyn_Syntax.Sig_pragma ((((trans_pragma p)), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[])))
end
| FStar_Parser_AST.TopLevelModule (id) -> begin
((env), ([]))
end
| FStar_Parser_AST.Open (lid) -> begin
(

let env = (FStar_Parser_DesugarEnv.push_namespace env lid)
in ((env), ([])))
end
| FStar_Parser_AST.Include (_72_2843) -> begin
(failwith "include not supported by legacy desugaring")
end
| FStar_Parser_AST.ModuleAbbrev (x, l) -> begin
(let _173_1039 = (FStar_Parser_DesugarEnv.push_module_abbrev env x l)
in ((_173_1039), ([])))
end
| FStar_Parser_AST.Tycon (is_effect, tcs) -> begin
(

let quals = if is_effect then begin
(FStar_Parser_AST.Effect_qual)::d.FStar_Parser_AST.quals
end else begin
d.FStar_Parser_AST.quals
end
in (

let tcs = (FStar_List.map (fun _72_2857 -> (match (_72_2857) with
| (x, _72_2856) -> begin
x
end)) tcs)
in (let _173_1041 = (trans_quals quals)
in (desugar_tycon env d.FStar_Parser_AST.drange _173_1041 tcs))))
end
| FStar_Parser_AST.TopLevelLet (isrec, lets) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (match ((let _173_1043 = (let _173_1042 = (desugar_exp_maybe_top true env (FStar_Parser_AST.mk_term (FStar_Parser_AST.Let (((isrec), (lets), ((FStar_Parser_AST.mk_term (FStar_Parser_AST.Const (FStar_Const.Const_unit)) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))))) d.FStar_Parser_AST.drange FStar_Parser_AST.Expr))
in (FStar_All.pipe_left FStar_Absyn_Util.compress_exp _173_1042))
in _173_1043.FStar_Absyn_Syntax.n)) with
| FStar_Absyn_Syntax.Exp_let (lbs, _72_2866) -> begin
(

let lids = (FStar_All.pipe_right (Prims.snd lbs) (FStar_List.map (fun lb -> (match (lb.FStar_Absyn_Syntax.lbname) with
| FStar_Util.Inr (l) -> begin
l
end
| _72_2873 -> begin
(failwith "impossible")
end))))
in (

let quals = (match (quals) with
| (_72_2878)::_72_2876 -> begin
(trans_quals quals)
end
| _72_2881 -> begin
(FStar_All.pipe_right (Prims.snd lbs) (FStar_List.collect (fun uu___437 -> (match (uu___437) with
| {FStar_Absyn_Syntax.lbname = FStar_Util.Inl (_72_2890); FStar_Absyn_Syntax.lbtyp = _72_2888; FStar_Absyn_Syntax.lbeff = _72_2886; FStar_Absyn_Syntax.lbdef = _72_2884} -> begin
[]
end
| {FStar_Absyn_Syntax.lbname = FStar_Util.Inr (l); FStar_Absyn_Syntax.lbtyp = _72_2898; FStar_Absyn_Syntax.lbeff = _72_2896; FStar_Absyn_Syntax.lbdef = _72_2894} -> begin
(FStar_Parser_DesugarEnv.lookup_letbinding_quals env l)
end))))
end)
in (

let s = FStar_Absyn_Syntax.Sig_let (((lbs), (d.FStar_Parser_AST.drange), (lids), (quals)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env s)
in ((env), ((s)::[]))))))
end
| _72_2906 -> begin
(failwith "Desugaring a let did not produce a let")
end))
end
| FStar_Parser_AST.Main (t) -> begin
(

let e = (desugar_exp env t)
in (

let se = FStar_Absyn_Syntax.Sig_main (((e), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[]))))
end
| FStar_Parser_AST.Assume (id, t) -> begin
(

let f = (desugar_formula env t)
in (let _173_1049 = (let _173_1048 = (let _173_1047 = (let _173_1046 = (FStar_Parser_DesugarEnv.qualify env id)
in ((_173_1046), (f), ((FStar_Absyn_Syntax.Assumption)::[]), (d.FStar_Parser_AST.drange)))
in FStar_Absyn_Syntax.Sig_assume (_173_1047))
in (_173_1048)::[])
in ((env), (_173_1049))))
end
| FStar_Parser_AST.Val (id, t) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let t = (let _173_1050 = (close_fun env t)
in (desugar_typ env _173_1050))
in (

let quals = if (env.FStar_Parser_DesugarEnv.iface && env.FStar_Parser_DesugarEnv.admitted_iface) then begin
(let _173_1051 = (trans_quals quals)
in (FStar_Absyn_Syntax.Assumption)::_173_1051)
end else begin
(trans_quals quals)
end
in (

let se = (let _173_1053 = (let _173_1052 = (FStar_Parser_DesugarEnv.qualify env id)
in ((_173_1052), (t), (quals), (d.FStar_Parser_AST.drange)))
in FStar_Absyn_Syntax.Sig_val_decl (_173_1053))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se)
in ((env), ((se)::[])))))))
end
| FStar_Parser_AST.Exception (id, None) -> begin
(

let t = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) FStar_Absyn_Const.exn_lid)
in (

let l = (FStar_Parser_DesugarEnv.qualify env id)
in (

let se = FStar_Absyn_Syntax.Sig_datacon (((l), (t), (((FStar_Absyn_Const.exn_lid), ([]), (FStar_Absyn_Syntax.ktype))), ((FStar_Absyn_Syntax.ExceptionConstructor)::[]), ((FStar_Absyn_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Absyn_Syntax.Sig_bundle ((((se)::[]), ((FStar_Absyn_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se')
in (

let data_ops = (mk_data_projectors env se)
in (

let discs = (mk_data_discriminators [] env FStar_Absyn_Const.exn_lid [] FStar_Absyn_Syntax.ktype ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_DesugarEnv.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops)))))))))))
end
| FStar_Parser_AST.Exception (id, Some (term)) -> begin
(

let t = (desugar_typ env term)
in (

let t = (let _173_1058 = (let _173_1057 = (let _173_1054 = (FStar_Absyn_Syntax.null_v_binder t)
in (_173_1054)::[])
in (let _173_1056 = (let _173_1055 = (FStar_Parser_DesugarEnv.fail_or env (FStar_Parser_DesugarEnv.try_lookup_typ_name env) FStar_Absyn_Const.exn_lid)
in (FStar_Absyn_Syntax.mk_Total _173_1055))
in ((_173_1057), (_173_1056))))
in (FStar_Absyn_Syntax.mk_Typ_fun _173_1058 None d.FStar_Parser_AST.drange))
in (

let l = (FStar_Parser_DesugarEnv.qualify env id)
in (

let se = FStar_Absyn_Syntax.Sig_datacon (((l), (t), (((FStar_Absyn_Const.exn_lid), ([]), (FStar_Absyn_Syntax.ktype))), ((FStar_Absyn_Syntax.ExceptionConstructor)::[]), ((FStar_Absyn_Const.exn_lid)::[]), (d.FStar_Parser_AST.drange)))
in (

let se' = FStar_Absyn_Syntax.Sig_bundle ((((se)::[]), ((FStar_Absyn_Syntax.ExceptionConstructor)::[]), ((l)::[]), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se')
in (

let data_ops = (mk_data_projectors env se)
in (

let discs = (mk_data_discriminators [] env FStar_Absyn_Const.exn_lid [] FStar_Absyn_Syntax.ktype ((l)::[]))
in (

let env = (FStar_List.fold_left FStar_Parser_DesugarEnv.push_sigelt env (FStar_List.append discs data_ops))
in ((env), ((FStar_List.append ((se')::discs) data_ops))))))))))))
end
| FStar_Parser_AST.KindAbbrev (id, binders, k) -> begin
(

let _72_2958 = (desugar_binders env binders)
in (match (_72_2958) with
| (env_k, binders) -> begin
(

let k = (desugar_kind env_k k)
in (

let name = (FStar_Parser_DesugarEnv.qualify env id)
in (

let se = FStar_Absyn_Syntax.Sig_kind_abbrev (((name), (binders), (k), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env se)
in ((env), ((se)::[]))))))
end))
end
| FStar_Parser_AST.NewEffectForFree (_72_2964) -> begin
(failwith "effects for free only supported in conjunction with --universes")
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect (eff_name, eff_binders, defn)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let env0 = env
in (

let _72_2976 = (desugar_binders env eff_binders)
in (match (_72_2976) with
| (env, binders) -> begin
(

let defn = (desugar_typ env defn)
in (

let _72_2980 = (FStar_Absyn_Util.head_and_args defn)
in (match (_72_2980) with
| (head, args) -> begin
(match (head.FStar_Absyn_Syntax.n) with
| FStar_Absyn_Syntax.Typ_const (eff) -> begin
(match ((FStar_Parser_DesugarEnv.try_lookup_effect_defn env eff.FStar_Absyn_Syntax.v)) with
| None -> begin
(let _173_1063 = (let _173_1062 = (let _173_1061 = (let _173_1060 = (let _173_1059 = (FStar_Absyn_Print.sli eff.FStar_Absyn_Syntax.v)
in (Prims.strcat _173_1059 " not found"))
in (Prims.strcat "Effect " _173_1060))
in ((_173_1061), (d.FStar_Parser_AST.drange)))
in FStar_Errors.Error (_173_1062))
in (Prims.raise _173_1063))
end
| Some (ed) -> begin
(

let subst = (FStar_Absyn_Util.subst_of_list ed.FStar_Absyn_Syntax.binders args)
in (

let sub = (FStar_Absyn_Util.subst_typ subst)
in (

let ed = (let _173_1081 = (FStar_Parser_DesugarEnv.qualify env0 eff_name)
in (let _173_1080 = (trans_quals quals)
in (let _173_1079 = (FStar_Absyn_Util.subst_kind subst ed.FStar_Absyn_Syntax.signature)
in (let _173_1078 = (sub ed.FStar_Absyn_Syntax.ret)
in (let _173_1077 = (sub ed.FStar_Absyn_Syntax.bind_wp)
in (let _173_1076 = (sub ed.FStar_Absyn_Syntax.bind_wlp)
in (let _173_1075 = (sub ed.FStar_Absyn_Syntax.if_then_else)
in (let _173_1074 = (sub ed.FStar_Absyn_Syntax.ite_wp)
in (let _173_1073 = (sub ed.FStar_Absyn_Syntax.ite_wlp)
in (let _173_1072 = (sub ed.FStar_Absyn_Syntax.wp_binop)
in (let _173_1071 = (sub ed.FStar_Absyn_Syntax.wp_as_type)
in (let _173_1070 = (sub ed.FStar_Absyn_Syntax.close_wp)
in (let _173_1069 = (sub ed.FStar_Absyn_Syntax.close_wp_t)
in (let _173_1068 = (sub ed.FStar_Absyn_Syntax.assert_p)
in (let _173_1067 = (sub ed.FStar_Absyn_Syntax.assume_p)
in (let _173_1066 = (sub ed.FStar_Absyn_Syntax.null_wp)
in (let _173_1065 = (sub ed.FStar_Absyn_Syntax.trivial)
in {FStar_Absyn_Syntax.mname = _173_1081; FStar_Absyn_Syntax.binders = binders; FStar_Absyn_Syntax.qualifiers = _173_1080; FStar_Absyn_Syntax.signature = _173_1079; FStar_Absyn_Syntax.ret = _173_1078; FStar_Absyn_Syntax.bind_wp = _173_1077; FStar_Absyn_Syntax.bind_wlp = _173_1076; FStar_Absyn_Syntax.if_then_else = _173_1075; FStar_Absyn_Syntax.ite_wp = _173_1074; FStar_Absyn_Syntax.ite_wlp = _173_1073; FStar_Absyn_Syntax.wp_binop = _173_1072; FStar_Absyn_Syntax.wp_as_type = _173_1071; FStar_Absyn_Syntax.close_wp = _173_1070; FStar_Absyn_Syntax.close_wp_t = _173_1069; FStar_Absyn_Syntax.assert_p = _173_1068; FStar_Absyn_Syntax.assume_p = _173_1067; FStar_Absyn_Syntax.null_wp = _173_1066; FStar_Absyn_Syntax.trivial = _173_1065})))))))))))))))))
in (

let se = FStar_Absyn_Syntax.Sig_new_effect (((ed), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env0 se)
in ((env), ((se)::[])))))))
end)
end
| _72_2992 -> begin
(let _173_1085 = (let _173_1084 = (let _173_1083 = (let _173_1082 = (FStar_Absyn_Print.typ_to_string head)
in (Prims.strcat _173_1082 " is not an effect"))
in ((_173_1083), (d.FStar_Parser_AST.drange)))
in FStar_Errors.Error (_173_1084))
in (Prims.raise _173_1085))
end)
end)))
end))))
end
| FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect (eff_name, eff_binders, eff_kind, eff_decls, _actions)) -> begin
(

let quals = d.FStar_Parser_AST.quals
in (

let env0 = env
in (

let env = (FStar_Parser_DesugarEnv.enter_monad_scope env eff_name)
in (

let _72_3006 = (desugar_binders env eff_binders)
in (match (_72_3006) with
| (env, binders) -> begin
(

let eff_k = (desugar_kind env eff_kind)
in (

let _72_3017 = (FStar_All.pipe_right eff_decls (FStar_List.fold_left (fun _72_3010 decl -> (match (_72_3010) with
| (env, out) -> begin
(

let _72_3014 = (desugar_decl env decl)
in (match (_72_3014) with
| (env, ses) -> begin
(let _173_1089 = (let _173_1088 = (FStar_List.hd ses)
in (_173_1088)::out)
in ((env), (_173_1089)))
end))
end)) ((env), ([]))))
in (match (_72_3017) with
| (env, decls) -> begin
(

let decls = (FStar_List.rev decls)
in (

let lookup = (fun s -> (match ((let _173_1093 = (let _173_1092 = (FStar_Absyn_Syntax.mk_ident ((s), (d.FStar_Parser_AST.drange)))
in (FStar_Parser_DesugarEnv.qualify env _173_1092))
in (FStar_Parser_DesugarEnv.try_resolve_typ_abbrev env _173_1093))) with
| None -> begin
(Prims.raise (FStar_Errors.Error ((((Prims.strcat "Monad " (Prims.strcat eff_name.FStar_Ident.idText (Prims.strcat " expects definition of " s)))), (d.FStar_Parser_AST.drange)))))
end
| Some (t) -> begin
t
end))
in (

let ed = (let _173_1109 = (FStar_Parser_DesugarEnv.qualify env0 eff_name)
in (let _173_1108 = (trans_quals quals)
in (let _173_1107 = (lookup "return")
in (let _173_1106 = (lookup "bind_wp")
in (let _173_1105 = (lookup "bind_wlp")
in (let _173_1104 = (lookup "if_then_else")
in (let _173_1103 = (lookup "ite_wp")
in (let _173_1102 = (lookup "ite_wlp")
in (let _173_1101 = (lookup "wp_binop")
in (let _173_1100 = (lookup "wp_as_type")
in (let _173_1099 = (lookup "close_wp")
in (let _173_1098 = (lookup "close_wp_t")
in (let _173_1097 = (lookup "assert_p")
in (let _173_1096 = (lookup "assume_p")
in (let _173_1095 = (lookup "null_wp")
in (let _173_1094 = (lookup "trivial")
in {FStar_Absyn_Syntax.mname = _173_1109; FStar_Absyn_Syntax.binders = binders; FStar_Absyn_Syntax.qualifiers = _173_1108; FStar_Absyn_Syntax.signature = eff_k; FStar_Absyn_Syntax.ret = _173_1107; FStar_Absyn_Syntax.bind_wp = _173_1106; FStar_Absyn_Syntax.bind_wlp = _173_1105; FStar_Absyn_Syntax.if_then_else = _173_1104; FStar_Absyn_Syntax.ite_wp = _173_1103; FStar_Absyn_Syntax.ite_wlp = _173_1102; FStar_Absyn_Syntax.wp_binop = _173_1101; FStar_Absyn_Syntax.wp_as_type = _173_1100; FStar_Absyn_Syntax.close_wp = _173_1099; FStar_Absyn_Syntax.close_wp_t = _173_1098; FStar_Absyn_Syntax.assert_p = _173_1097; FStar_Absyn_Syntax.assume_p = _173_1096; FStar_Absyn_Syntax.null_wp = _173_1095; FStar_Absyn_Syntax.trivial = _173_1094}))))))))))))))))
in (

let se = FStar_Absyn_Syntax.Sig_new_effect (((ed), (d.FStar_Parser_AST.drange)))
in (

let env = (FStar_Parser_DesugarEnv.push_sigelt env0 se)
in ((env), ((se)::[])))))))
end)))
end)))))
end
| FStar_Parser_AST.SubEffect (l) -> begin
(

let lookup = (fun l -> (match ((FStar_Parser_DesugarEnv.try_lookup_effect_name env l)) with
| None -> begin
(let _173_1116 = (let _173_1115 = (let _173_1114 = (let _173_1113 = (let _173_1112 = (FStar_Absyn_Print.sli l)
in (Prims.strcat _173_1112 " not found"))
in (Prims.strcat "Effect name " _173_1113))
in ((_173_1114), (d.FStar_Parser_AST.drange)))
in FStar_Errors.Error (_173_1115))
in (Prims.raise _173_1116))
end
| Some (l) -> begin
l
end))
in (

let src = (lookup l.FStar_Parser_AST.msource)
in (

let dst = (lookup l.FStar_Parser_AST.mdest)
in (

let non_reifiable = (fun uu___438 -> (match (uu___438) with
| FStar_Parser_AST.NonReifiableLift (f) -> begin
f
end
| _72_3040 -> begin
(Prims.raise (FStar_Errors.Error ((("Unexpected reifiable sub-effect"), (d.FStar_Parser_AST.drange)))))
end))
in (

let lift = (let _173_1119 = (non_reifiable l.FStar_Parser_AST.lift_op)
in (desugar_typ env _173_1119))
in (

let se = FStar_Absyn_Syntax.Sig_sub_effect ((({FStar_Absyn_Syntax.source = src; FStar_Absyn_Syntax.target = dst; FStar_Absyn_Syntax.lift = lift}), (d.FStar_Parser_AST.drange)))
in ((env), ((se)::[]))))))))
end)))


let desugar_decls : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.decl Prims.list  ->  (FStar_Parser_DesugarEnv.env * FStar_Absyn_Syntax.sigelts) = (fun env decls -> (FStar_List.fold_left (fun _72_3048 d -> (match (_72_3048) with
| (env, sigelts) -> begin
(

let _72_3052 = (desugar_decl env d)
in (match (_72_3052) with
| (env, se) -> begin
((env), ((FStar_List.append sigelts se)))
end))
end)) ((env), ([])) decls))


let open_prims_all : (FStar_Parser_AST.decoration Prims.list  ->  FStar_Parser_AST.decl) Prims.list = ((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Absyn_Const.prims_lid)) FStar_Absyn_Syntax.dummyRange))::((FStar_Parser_AST.mk_decl (FStar_Parser_AST.Open (FStar_Absyn_Const.all_lid)) FStar_Absyn_Syntax.dummyRange))::[]


let desugar_modul_common : FStar_Absyn_Syntax.modul Prims.option  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Absyn_Syntax.modul * Prims.bool) = (fun curmod env m -> (

let open_ns = (fun mname d -> (

let d = if ((FStar_List.length mname.FStar_Ident.ns) <> (Prims.parse_int "0")) then begin
(let _173_1144 = (let _173_1143 = (let _173_1141 = (FStar_Absyn_Syntax.lid_of_ids mname.FStar_Ident.ns)
in FStar_Parser_AST.Open (_173_1141))
in (let _173_1142 = (FStar_Absyn_Syntax.range_of_lid mname)
in (FStar_Parser_AST.mk_decl _173_1143 _173_1142 [])))
in (_173_1144)::d)
end else begin
d
end
in d))
in (

let env = (match (curmod) with
| None -> begin
env
end
| Some (prev_mod) -> begin
(FStar_Parser_DesugarEnv.finish_module_or_interface env prev_mod)
end)
in (

let _72_3079 = (match (m) with
| FStar_Parser_AST.Interface (mname, decls, admitted) -> begin
(let _173_1146 = (FStar_Parser_DesugarEnv.prepare_module_or_interface true admitted env mname)
in (let _173_1145 = (open_ns mname decls)
in ((_173_1146), (mname), (_173_1145), (true))))
end
| FStar_Parser_AST.Module (mname, decls) -> begin
(let _173_1148 = (FStar_Parser_DesugarEnv.prepare_module_or_interface false false env mname)
in (let _173_1147 = (open_ns mname decls)
in ((_173_1148), (mname), (_173_1147), (false))))
end)
in (match (_72_3079) with
| ((env, pop_when_done), mname, decls, intf) -> begin
(

let _72_3082 = (desugar_decls env decls)
in (match (_72_3082) with
| (env, sigelts) -> begin
(

let modul = {FStar_Absyn_Syntax.name = mname; FStar_Absyn_Syntax.declarations = sigelts; FStar_Absyn_Syntax.exports = []; FStar_Absyn_Syntax.is_interface = intf; FStar_Absyn_Syntax.is_deserialized = false}
in ((env), (modul), (pop_when_done)))
end))
end)))))


let desugar_partial_modul : FStar_Absyn_Syntax.modul Prims.option  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.modul  ->  (FStar_Parser_DesugarEnv.env * FStar_Absyn_Syntax.modul) = (fun curmod env m -> (

let m = if false then begin
(match (m) with
| FStar_Parser_AST.Module (mname, decls) -> begin
FStar_Parser_AST.Interface (((mname), (decls), (true)))
end
| FStar_Parser_AST.Interface (mname, _72_3093, _72_3095) -> begin
(failwith (Prims.strcat "Impossible: " mname.FStar_Ident.ident.FStar_Ident.idText))
end)
end else begin
m
end
in (

let _72_3103 = (desugar_modul_common curmod env m)
in (match (_72_3103) with
| (x, y, _72_3102) -> begin
((x), (y))
end))))


let desugar_modul : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.modul  ->  (env_t * FStar_Absyn_Syntax.modul) = (fun env m -> (

let _72_3109 = (desugar_modul_common None env m)
in (match (_72_3109) with
| (env, modul, pop_when_done) -> begin
(

let env = (FStar_Parser_DesugarEnv.finish_module_or_interface env modul)
in (

let _72_3111 = if (FStar_Options.dump_module modul.FStar_Absyn_Syntax.name.FStar_Ident.str) then begin
(let _173_1159 = (FStar_Absyn_Print.modul_to_string modul)
in (FStar_Util.print1 "%s\n" _173_1159))
end else begin
()
end
in (let _173_1160 = if pop_when_done then begin
(FStar_Parser_DesugarEnv.export_interface modul.FStar_Absyn_Syntax.name env)
end else begin
env
end
in ((_173_1160), (modul)))))
end)))


let desugar_file : FStar_Parser_DesugarEnv.env  ->  FStar_Parser_AST.file  ->  (FStar_Parser_DesugarEnv.env * FStar_Absyn_Syntax.modul Prims.list) = (fun env f -> (

let _72_3124 = (FStar_List.fold_left (fun _72_3117 m -> (match (_72_3117) with
| (env, mods) -> begin
(

let _72_3121 = (desugar_modul env m)
in (match (_72_3121) with
| (env, m) -> begin
((env), ((m)::mods))
end))
end)) ((env), ([])) f)
in (match (_72_3124) with
| (env, mods) -> begin
((env), ((FStar_List.rev mods)))
end)))


let add_modul_to_env : FStar_Absyn_Syntax.modul  ->  FStar_Parser_DesugarEnv.env  ->  FStar_Parser_DesugarEnv.env = (fun m en -> (

let _72_3129 = (FStar_Parser_DesugarEnv.prepare_module_or_interface false false en m.FStar_Absyn_Syntax.name)
in (match (_72_3129) with
| (en, pop_when_done) -> begin
(

let en = (FStar_List.fold_left FStar_Parser_DesugarEnv.push_sigelt (

let _72_3130 = en
in {FStar_Parser_DesugarEnv.curmodule = Some (m.FStar_Absyn_Syntax.name); FStar_Parser_DesugarEnv.modules = _72_3130.FStar_Parser_DesugarEnv.modules; FStar_Parser_DesugarEnv.open_namespaces = _72_3130.FStar_Parser_DesugarEnv.open_namespaces; FStar_Parser_DesugarEnv.modul_abbrevs = _72_3130.FStar_Parser_DesugarEnv.modul_abbrevs; FStar_Parser_DesugarEnv.sigaccum = _72_3130.FStar_Parser_DesugarEnv.sigaccum; FStar_Parser_DesugarEnv.localbindings = _72_3130.FStar_Parser_DesugarEnv.localbindings; FStar_Parser_DesugarEnv.recbindings = _72_3130.FStar_Parser_DesugarEnv.recbindings; FStar_Parser_DesugarEnv.phase = _72_3130.FStar_Parser_DesugarEnv.phase; FStar_Parser_DesugarEnv.sigmap = _72_3130.FStar_Parser_DesugarEnv.sigmap; FStar_Parser_DesugarEnv.default_result_effect = _72_3130.FStar_Parser_DesugarEnv.default_result_effect; FStar_Parser_DesugarEnv.iface = _72_3130.FStar_Parser_DesugarEnv.iface; FStar_Parser_DesugarEnv.admitted_iface = _72_3130.FStar_Parser_DesugarEnv.admitted_iface}) m.FStar_Absyn_Syntax.exports)
in (

let env = (FStar_Parser_DesugarEnv.finish_module_or_interface en m)
in if pop_when_done then begin
(FStar_Parser_DesugarEnv.export_interface m.FStar_Absyn_Syntax.name env)
end else begin
env
end))
end)))




