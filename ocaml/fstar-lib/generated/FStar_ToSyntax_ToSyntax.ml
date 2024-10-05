open Prims
type extension_tosyntax_decl_t =
  FStar_Syntax_DsEnv.env ->
    FStar_Dyn.dyn ->
      FStar_Ident.lident Prims.list ->
        FStar_Compiler_Range_Type.range ->
          FStar_Syntax_Syntax.sigelt' Prims.list
let (extension_tosyntax_table :
  extension_tosyntax_decl_t FStar_Compiler_Util.smap) =
  FStar_Compiler_Util.smap_create (Prims.of_int (20))
let (register_extension_tosyntax :
  Prims.string -> extension_tosyntax_decl_t -> unit) =
  fun lang_name ->
    fun cb ->
      FStar_Compiler_Util.smap_add extension_tosyntax_table lang_name cb
let (lookup_extension_tosyntax :
  Prims.string -> extension_tosyntax_decl_t FStar_Pervasives_Native.option) =
  fun lang_name ->
    FStar_Compiler_Util.smap_try_find extension_tosyntax_table lang_name
let (dbg_attrs : Prims.bool FStar_Compiler_Effect.ref) =
  FStar_Compiler_Debug.get_toggle "attrs"
let (dbg_ToSyntax : Prims.bool FStar_Compiler_Effect.ref) =
  FStar_Compiler_Debug.get_toggle "ToSyntax"
type antiquotations_temp =
  (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term) Prims.list
let (tun_r : FStar_Compiler_Range_Type.range -> FStar_Syntax_Syntax.term) =
  fun r ->
    {
      FStar_Syntax_Syntax.n = (FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.n);
      FStar_Syntax_Syntax.pos = r;
      FStar_Syntax_Syntax.vars =
        (FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.vars);
      FStar_Syntax_Syntax.hash_code =
        (FStar_Syntax_Syntax.tun.FStar_Syntax_Syntax.hash_code)
    }
type annotated_pat =
  (FStar_Syntax_Syntax.pat * (FStar_Syntax_Syntax.bv *
    FStar_Syntax_Syntax.typ * FStar_Syntax_Syntax.term Prims.list)
    Prims.list)
let (mk_thunk :
  FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun e ->
    let b =
      let uu___ =
        FStar_Syntax_Syntax.new_bv FStar_Pervasives_Native.None
          FStar_Syntax_Syntax.tun in
      FStar_Syntax_Syntax.mk_binder uu___ in
    FStar_Syntax_Util.abs [b] e FStar_Pervasives_Native.None
let (mk_binder_with_attrs :
  FStar_Syntax_Syntax.bv ->
    FStar_Syntax_Syntax.bqual ->
      FStar_Syntax_Syntax.attribute Prims.list -> FStar_Syntax_Syntax.binder)
  =
  fun bv ->
    fun aq ->
      fun attrs ->
        let uu___ = FStar_Syntax_Util.parse_positivity_attributes attrs in
        match uu___ with
        | (pqual, attrs1) ->
            FStar_Syntax_Syntax.mk_binder_with_attrs bv aq pqual attrs1
let (qualify_field_names :
  FStar_Ident.lident ->
    FStar_Ident.lident Prims.list -> FStar_Ident.lident Prims.list)
  =
  fun record_or_dc_lid ->
    fun field_names ->
      let qualify_to_record l =
        let ns = FStar_Ident.ns_of_lid record_or_dc_lid in
        let uu___ = FStar_Ident.ident_of_lid l in
        FStar_Ident.lid_of_ns_and_id ns uu___ in
      let uu___ =
        FStar_Compiler_List.fold_left
          (fun uu___1 ->
             fun l ->
               match uu___1 with
               | (ns_opt, out) ->
                   let uu___2 = FStar_Ident.nsstr l in
                   (match uu___2 with
                    | "" ->
                        if FStar_Compiler_Option.isSome ns_opt
                        then
                          let uu___3 =
                            let uu___4 = qualify_to_record l in uu___4 :: out in
                          (ns_opt, uu___3)
                        else (ns_opt, (l :: out))
                    | ns ->
                        (match ns_opt with
                         | FStar_Pervasives_Native.Some ns' ->
                             if ns <> ns'
                             then
                               let uu___3 =
                                 let uu___4 =
                                   FStar_Class_Show.show
                                     FStar_Ident.showable_lident l in
                                 FStar_Compiler_Util.format2
                                   "Field %s of record type was expected to be scoped to namespace %s"
                                   uu___4 ns' in
                               FStar_Errors.raise_error
                                 FStar_Ident.hasrange_lident l
                                 FStar_Errors_Codes.Fatal_MissingFieldInRecord
                                 ()
                                 (Obj.magic
                                    FStar_Errors_Msg.is_error_message_string)
                                 (Obj.magic uu___3)
                             else
                               (let uu___4 =
                                  let uu___5 = qualify_to_record l in uu___5
                                    :: out in
                                (ns_opt, uu___4))
                         | FStar_Pervasives_Native.None ->
                             let uu___3 =
                               let uu___4 = qualify_to_record l in uu___4 ::
                                 out in
                             ((FStar_Pervasives_Native.Some ns), uu___3))))
          (FStar_Pervasives_Native.None, []) field_names in
      match uu___ with
      | (uu___1, field_names_rev) -> FStar_Compiler_List.rev field_names_rev
let desugar_disjunctive_pattern :
  'uuuuu .
    (FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t *
      (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term'
      FStar_Syntax_Syntax.syntax * 'uuuuu) Prims.list) Prims.list ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax
        FStar_Pervasives_Native.option ->
        FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.branch Prims.list
  =
  fun annotated_pats ->
    fun when_opt ->
      fun branch ->
        FStar_Compiler_List.map
          (fun uu___ ->
             match uu___ with
             | (pat, annots) ->
                 let branch1 =
                   FStar_Compiler_List.fold_left
                     (fun br ->
                        fun uu___1 ->
                          match uu___1 with
                          | (bv, ty, uu___2) ->
                              let lb =
                                let uu___3 =
                                  FStar_Syntax_Syntax.bv_to_name bv in
                                FStar_Syntax_Util.mk_letbinding
                                  (FStar_Pervasives.Inl bv) [] ty
                                  FStar_Parser_Const.effect_Tot_lid uu___3 []
                                  br.FStar_Syntax_Syntax.pos in
                              let branch2 =
                                let uu___3 =
                                  let uu___4 =
                                    FStar_Syntax_Syntax.mk_binder bv in
                                  [uu___4] in
                                FStar_Syntax_Subst.close uu___3 branch in
                              FStar_Syntax_Syntax.mk
                                (FStar_Syntax_Syntax.Tm_let
                                   {
                                     FStar_Syntax_Syntax.lbs = (false, [lb]);
                                     FStar_Syntax_Syntax.body1 = branch2
                                   }) br.FStar_Syntax_Syntax.pos) branch
                     annots in
                 FStar_Syntax_Util.branch (pat, when_opt, branch1))
          annotated_pats
let (trans_qual :
  FStar_Compiler_Range_Type.range ->
    FStar_Ident.lident FStar_Pervasives_Native.option ->
      FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier)
  =
  fun r ->
    fun maybe_effect_id ->
      fun uu___ ->
        match uu___ with
        | FStar_Parser_AST.Private -> FStar_Syntax_Syntax.Private
        | FStar_Parser_AST.Assumption -> FStar_Syntax_Syntax.Assumption
        | FStar_Parser_AST.Unfold_for_unification_and_vcgen ->
            FStar_Syntax_Syntax.Unfold_for_unification_and_vcgen
        | FStar_Parser_AST.Inline_for_extraction ->
            FStar_Syntax_Syntax.Inline_for_extraction
        | FStar_Parser_AST.NoExtract -> FStar_Syntax_Syntax.NoExtract
        | FStar_Parser_AST.Irreducible -> FStar_Syntax_Syntax.Irreducible
        | FStar_Parser_AST.Logic -> FStar_Syntax_Syntax.Logic
        | FStar_Parser_AST.TotalEffect -> FStar_Syntax_Syntax.TotalEffect
        | FStar_Parser_AST.Effect_qual -> FStar_Syntax_Syntax.Effect
        | FStar_Parser_AST.New -> FStar_Syntax_Syntax.New
        | FStar_Parser_AST.Opaque ->
            ((let uu___2 =
                let uu___3 =
                  FStar_Errors_Msg.text
                    "The 'opaque' qualifier is deprecated since its use was strangely schizophrenic." in
                let uu___4 =
                  let uu___5 =
                    FStar_Errors_Msg.text
                      "There were two overloaded uses: (1) Given 'opaque val f : t', the behavior was to exclude the definition of 'f' to the SMT solver. This corresponds roughly to the new 'irreducible' qualifier. (2) Given 'opaque type t = t'', the behavior was to provide the definition of 't' to the SMT solver, but not to inline it, unless absolutely required for unification. This corresponds roughly to the behavior of 'unfoldable' (which is currently the default)." in
                  [uu___5] in
                uu___3 :: uu___4 in
              FStar_Errors.log_issue FStar_Class_HasRange.hasRange_range r
                FStar_Errors_Codes.Warning_DeprecatedOpaqueQualifier ()
                (Obj.magic FStar_Errors_Msg.is_error_message_list_doc)
                (Obj.magic uu___2));
             FStar_Syntax_Syntax.Visible_default)
        | FStar_Parser_AST.Reflectable ->
            (match maybe_effect_id with
             | FStar_Pervasives_Native.None ->
                 FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range
                   r FStar_Errors_Codes.Fatal_ReflectOnlySupportedOnEffects
                   () (Obj.magic FStar_Errors_Msg.is_error_message_string)
                   (Obj.magic "Qualifier reflect only supported on effects")
             | FStar_Pervasives_Native.Some effect_id ->
                 FStar_Syntax_Syntax.Reflectable effect_id)
        | FStar_Parser_AST.Reifiable -> FStar_Syntax_Syntax.Reifiable
        | FStar_Parser_AST.Noeq -> FStar_Syntax_Syntax.Noeq
        | FStar_Parser_AST.Unopteq -> FStar_Syntax_Syntax.Unopteq
        | FStar_Parser_AST.DefaultEffect ->
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              FStar_Errors_Codes.Fatal_DefaultQualifierNotAllowedOnEffects ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic
                 "The 'default' qualifier on effects is no longer supported")
        | FStar_Parser_AST.Inline ->
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              FStar_Errors_Codes.Fatal_UnsupportedQualifier ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic "Unsupported qualifier")
        | FStar_Parser_AST.Visible ->
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              FStar_Errors_Codes.Fatal_UnsupportedQualifier ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic "Unsupported qualifier")
let (trans_pragma : FStar_Parser_AST.pragma -> FStar_Syntax_Syntax.pragma) =
  fun uu___ ->
    match uu___ with
    | FStar_Parser_AST.ShowOptions -> FStar_Syntax_Syntax.ShowOptions
    | FStar_Parser_AST.SetOptions s -> FStar_Syntax_Syntax.SetOptions s
    | FStar_Parser_AST.ResetOptions sopt ->
        FStar_Syntax_Syntax.ResetOptions sopt
    | FStar_Parser_AST.PushOptions sopt ->
        FStar_Syntax_Syntax.PushOptions sopt
    | FStar_Parser_AST.PopOptions -> FStar_Syntax_Syntax.PopOptions
    | FStar_Parser_AST.RestartSolver -> FStar_Syntax_Syntax.RestartSolver
    | FStar_Parser_AST.PrintEffectsGraph ->
        FStar_Syntax_Syntax.PrintEffectsGraph
let (as_imp :
  FStar_Parser_AST.imp ->
    FStar_Syntax_Syntax.arg_qualifier FStar_Pervasives_Native.option)
  =
  fun uu___ ->
    match uu___ with
    | FStar_Parser_AST.Hash -> FStar_Syntax_Syntax.as_aqual_implicit true
    | uu___1 -> FStar_Pervasives_Native.None
let arg_withimp_t :
  'uuuuu .
    FStar_Parser_AST.imp ->
      'uuuuu ->
        ('uuuuu * FStar_Syntax_Syntax.arg_qualifier
          FStar_Pervasives_Native.option)
  = fun imp -> fun t -> let uu___ = as_imp imp in (t, uu___)
let (contains_binder : FStar_Parser_AST.binder Prims.list -> Prims.bool) =
  fun binders ->
    FStar_Compiler_Util.for_some
      (fun b ->
         match b.FStar_Parser_AST.b with
         | FStar_Parser_AST.Annotated uu___ -> true
         | uu___ -> false) binders
let rec (unparen : FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun t ->
    match t.FStar_Parser_AST.tm with
    | FStar_Parser_AST.Paren t1 -> unparen t1
    | uu___ -> t
let (tm_type_z : FStar_Compiler_Range_Type.range -> FStar_Parser_AST.term) =
  fun r ->
    let uu___ =
      let uu___1 = FStar_Ident.lid_of_path ["Type0"] r in
      FStar_Parser_AST.Name uu___1 in
    FStar_Parser_AST.mk_term uu___ r FStar_Parser_AST.Kind
let (tm_type : FStar_Compiler_Range_Type.range -> FStar_Parser_AST.term) =
  fun r ->
    let uu___ =
      let uu___1 = FStar_Ident.lid_of_path ["Type"] r in
      FStar_Parser_AST.Name uu___1 in
    FStar_Parser_AST.mk_term uu___ r FStar_Parser_AST.Kind
let rec (is_comp_type :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> Prims.bool) =
  fun env ->
    fun t ->
      let uu___ = let uu___1 = unparen t in uu___1.FStar_Parser_AST.tm in
      match uu___ with
      | FStar_Parser_AST.Name l when
          (let uu___1 = FStar_Syntax_DsEnv.current_module env in
           FStar_Ident.lid_equals uu___1 FStar_Parser_Const.prims_lid) &&
            (let s =
               let uu___1 = FStar_Ident.ident_of_lid l in
               FStar_Ident.string_of_id uu___1 in
             (s = "Tot") || (s = "GTot"))
          -> true
      | FStar_Parser_AST.Name l ->
          let uu___1 = FStar_Syntax_DsEnv.try_lookup_effect_name env l in
          FStar_Compiler_Option.isSome uu___1
      | FStar_Parser_AST.Construct (l, uu___1) ->
          let uu___2 = FStar_Syntax_DsEnv.try_lookup_effect_name env l in
          FStar_Compiler_Option.isSome uu___2
      | FStar_Parser_AST.App (head, uu___1, uu___2) -> is_comp_type env head
      | FStar_Parser_AST.Paren t1 ->
          FStar_Compiler_Effect.failwith "impossible"
      | FStar_Parser_AST.Ascribed (t1, uu___1, uu___2, uu___3) ->
          is_comp_type env t1
      | FStar_Parser_AST.LetOpen (uu___1, t1) -> is_comp_type env t1
      | uu___1 -> false
let (unit_ty : FStar_Compiler_Range_Type.range -> FStar_Parser_AST.term) =
  fun rng ->
    FStar_Parser_AST.mk_term
      (FStar_Parser_AST.Name FStar_Parser_Const.unit_lid) rng
      FStar_Parser_AST.Type_level
type env_t = FStar_Syntax_DsEnv.env
type lenv_t = FStar_Syntax_Syntax.bv Prims.list
let (desugar_name' :
  (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
    env_t ->
      Prims.bool ->
        FStar_Ident.lid ->
          FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun setpos ->
    fun env ->
      fun resolve ->
        fun l ->
          let tm_attrs_opt =
            if resolve
            then FStar_Syntax_DsEnv.try_lookup_lid_with_attributes env l
            else
              FStar_Syntax_DsEnv.try_lookup_lid_with_attributes_no_resolve
                env l in
          match tm_attrs_opt with
          | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
          | FStar_Pervasives_Native.Some (tm, attrs) ->
              let tm1 = setpos tm in FStar_Pervasives_Native.Some tm1
let desugar_name :
  'uuuuu .
    'uuuuu ->
      (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
        env_t -> Prims.bool -> FStar_Ident.lident -> FStar_Syntax_Syntax.term
  =
  fun mk ->
    fun setpos ->
      fun env ->
        fun resolve ->
          fun l ->
            FStar_Syntax_DsEnv.fail_or env (desugar_name' setpos env resolve)
              l
let (compile_op_lid :
  Prims.int ->
    Prims.string -> FStar_Compiler_Range_Type.range -> FStar_Ident.lident)
  =
  fun n ->
    fun s ->
      fun r ->
        let uu___ =
          let uu___1 =
            let uu___2 =
              let uu___3 = FStar_Parser_AST.compile_op n s r in (uu___3, r) in
            FStar_Ident.mk_ident uu___2 in
          [uu___1] in
        FStar_Ident.lid_of_ids uu___
let (op_as_term :
  env_t ->
    Prims.int ->
      FStar_Ident.ident ->
        FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)
  =
  fun env ->
    fun arity ->
      fun op ->
        let r l =
          let uu___ =
            let uu___1 =
              let uu___2 =
                let uu___3 = FStar_Ident.range_of_id op in
                FStar_Ident.set_lid_range l uu___3 in
              FStar_Syntax_Syntax.lid_and_dd_as_fv uu___2
                FStar_Pervasives_Native.None in
            FStar_Syntax_Syntax.fv_to_tm uu___1 in
          FStar_Pervasives_Native.Some uu___ in
        let fallback uu___ =
          let uu___1 = FStar_Ident.string_of_id op in
          match uu___1 with
          | "=" -> r FStar_Parser_Const.op_Eq
          | "<" -> r FStar_Parser_Const.op_LT
          | "<=" -> r FStar_Parser_Const.op_LTE
          | ">" -> r FStar_Parser_Const.op_GT
          | ">=" -> r FStar_Parser_Const.op_GTE
          | "&&" -> r FStar_Parser_Const.op_And
          | "||" -> r FStar_Parser_Const.op_Or
          | "+" -> r FStar_Parser_Const.op_Addition
          | "-" when arity = Prims.int_one -> r FStar_Parser_Const.op_Minus
          | "-" -> r FStar_Parser_Const.op_Subtraction
          | "/" -> r FStar_Parser_Const.op_Division
          | "%" -> r FStar_Parser_Const.op_Modulus
          | "@" ->
              ((let uu___3 =
                  let uu___4 =
                    FStar_Errors_Msg.text
                      "The operator '@' has been resolved to FStar.List.Tot.append even though FStar.List.Tot is not in scope. Please add an 'open FStar.List.Tot' to stop relying on this deprecated, special treatment of '@'." in
                  [uu___4] in
                FStar_Errors.log_issue FStar_Ident.hasrange_ident op
                  FStar_Errors_Codes.Warning_DeprecatedGeneric ()
                  (Obj.magic FStar_Errors_Msg.is_error_message_list_doc)
                  (Obj.magic uu___3));
               r FStar_Parser_Const.list_tot_append_lid)
          | "<>" -> r FStar_Parser_Const.op_notEq
          | "~" -> r FStar_Parser_Const.not_lid
          | "==" -> r FStar_Parser_Const.eq2_lid
          | "<<" -> r FStar_Parser_Const.precedes_lid
          | "/\\" -> r FStar_Parser_Const.and_lid
          | "\\/" -> r FStar_Parser_Const.or_lid
          | "==>" -> r FStar_Parser_Const.imp_lid
          | "<==>" -> r FStar_Parser_Const.iff_lid
          | uu___2 -> FStar_Pervasives_Native.None in
        let uu___ =
          let uu___1 =
            let uu___2 = FStar_Ident.string_of_id op in
            let uu___3 = FStar_Ident.range_of_id op in
            compile_op_lid arity uu___2 uu___3 in
          desugar_name'
            (fun t ->
               let uu___2 = FStar_Ident.range_of_id op in
               {
                 FStar_Syntax_Syntax.n = (t.FStar_Syntax_Syntax.n);
                 FStar_Syntax_Syntax.pos = uu___2;
                 FStar_Syntax_Syntax.vars = (t.FStar_Syntax_Syntax.vars);
                 FStar_Syntax_Syntax.hash_code =
                   (t.FStar_Syntax_Syntax.hash_code)
               }) env true uu___1 in
        match uu___ with
        | FStar_Pervasives_Native.Some t -> FStar_Pervasives_Native.Some t
        | uu___1 -> fallback ()
let (sort_ftv : FStar_Ident.ident Prims.list -> FStar_Ident.ident Prims.list)
  =
  fun ftv ->
    let uu___ =
      FStar_Compiler_Util.remove_dups
        (fun x ->
           fun y ->
             let uu___1 = FStar_Ident.string_of_id x in
             let uu___2 = FStar_Ident.string_of_id y in uu___1 = uu___2) ftv in
    FStar_Compiler_Util.sort_with
      (fun x ->
         fun y ->
           let uu___1 = FStar_Ident.string_of_id x in
           let uu___2 = FStar_Ident.string_of_id y in
           FStar_Compiler_String.compare uu___1 uu___2) uu___
let rec (free_vars_b :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.binder ->
        (FStar_Syntax_DsEnv.env * FStar_Ident.ident Prims.list))
  =
  fun tvars_only ->
    fun env ->
      fun binder ->
        match binder.FStar_Parser_AST.b with
        | FStar_Parser_AST.Variable x ->
            if tvars_only
            then (env, [])
            else
              (let uu___1 = FStar_Syntax_DsEnv.push_bv env x in
               match uu___1 with | (env1, uu___2) -> (env1, []))
        | FStar_Parser_AST.TVariable x ->
            let uu___ = FStar_Syntax_DsEnv.push_bv env x in
            (match uu___ with | (env1, uu___1) -> (env1, [x]))
        | FStar_Parser_AST.Annotated (x, term) ->
            if tvars_only
            then let uu___ = free_vars tvars_only env term in (env, uu___)
            else
              (let uu___1 = FStar_Syntax_DsEnv.push_bv env x in
               match uu___1 with
               | (env', uu___2) ->
                   let uu___3 = free_vars tvars_only env term in
                   (env', uu___3))
        | FStar_Parser_AST.TAnnotated (id, term) ->
            let uu___ = FStar_Syntax_DsEnv.push_bv env id in
            (match uu___ with
             | (env', uu___1) ->
                 let uu___2 = free_vars tvars_only env term in (env', uu___2))
        | FStar_Parser_AST.NoName t ->
            let uu___ = free_vars tvars_only env t in (env, uu___)
and (free_vars_bs :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.binder Prims.list ->
        (FStar_Syntax_DsEnv.env * FStar_Ident.ident Prims.list))
  =
  fun tvars_only ->
    fun env ->
      fun binders ->
        FStar_Compiler_List.fold_left
          (fun uu___ ->
             fun binder ->
               match uu___ with
               | (env1, free) ->
                   let uu___1 = free_vars_b tvars_only env1 binder in
                   (match uu___1 with
                    | (env2, f) -> (env2, (FStar_Compiler_List.op_At f free))))
          (env, []) binders
and (free_vars :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.term -> FStar_Ident.ident Prims.list)
  =
  fun tvars_only ->
    fun env ->
      fun t ->
        let uu___ = let uu___1 = unparen t in uu___1.FStar_Parser_AST.tm in
        match uu___ with
        | FStar_Parser_AST.Labeled uu___1 ->
            FStar_Compiler_Effect.failwith
              "Impossible --- labeled source term"
        | FStar_Parser_AST.Tvar a ->
            let uu___1 = FStar_Syntax_DsEnv.try_lookup_id env a in
            (match uu___1 with
             | FStar_Pervasives_Native.None -> [a]
             | uu___2 -> [])
        | FStar_Parser_AST.Var x ->
            if tvars_only
            then []
            else
              (let ids = FStar_Ident.ids_of_lid x in
               match ids with
               | id::[] ->
                   let uu___2 =
                     (let uu___3 = FStar_Syntax_DsEnv.try_lookup_id env id in
                      FStar_Pervasives_Native.uu___is_None uu___3) &&
                       (let uu___3 = FStar_Syntax_DsEnv.try_lookup_lid env x in
                        FStar_Pervasives_Native.uu___is_None uu___3) in
                   if uu___2 then [id] else []
               | uu___2 -> [])
        | FStar_Parser_AST.Wild -> []
        | FStar_Parser_AST.Const uu___1 -> []
        | FStar_Parser_AST.Uvar uu___1 -> []
        | FStar_Parser_AST.Projector uu___1 -> []
        | FStar_Parser_AST.Discrim uu___1 -> []
        | FStar_Parser_AST.Name uu___1 -> []
        | FStar_Parser_AST.Requires (t1, uu___1) ->
            free_vars tvars_only env t1
        | FStar_Parser_AST.Ensures (t1, uu___1) ->
            free_vars tvars_only env t1
        | FStar_Parser_AST.Decreases (t1, uu___1) ->
            free_vars tvars_only env t1
        | FStar_Parser_AST.NamedTyp (uu___1, t1) ->
            free_vars tvars_only env t1
        | FStar_Parser_AST.LexList l ->
            FStar_Compiler_List.collect (free_vars tvars_only env) l
        | FStar_Parser_AST.WFOrder (rel, e) ->
            let uu___1 = free_vars tvars_only env rel in
            let uu___2 = free_vars tvars_only env e in
            FStar_Compiler_List.op_At uu___1 uu___2
        | FStar_Parser_AST.Paren t1 ->
            FStar_Compiler_Effect.failwith "impossible"
        | FStar_Parser_AST.Ascribed (t1, t', tacopt, uu___1) ->
            let ts = t1 :: t' ::
              (match tacopt with
               | FStar_Pervasives_Native.None -> []
               | FStar_Pervasives_Native.Some t2 -> [t2]) in
            FStar_Compiler_List.collect (free_vars tvars_only env) ts
        | FStar_Parser_AST.Construct (uu___1, ts) ->
            FStar_Compiler_List.collect
              (fun uu___2 ->
                 match uu___2 with
                 | (t1, uu___3) -> free_vars tvars_only env t1) ts
        | FStar_Parser_AST.Op (uu___1, ts) ->
            FStar_Compiler_List.collect (free_vars tvars_only env) ts
        | FStar_Parser_AST.App (t1, t2, uu___1) ->
            let uu___2 = free_vars tvars_only env t1 in
            let uu___3 = free_vars tvars_only env t2 in
            FStar_Compiler_List.op_At uu___2 uu___3
        | FStar_Parser_AST.Refine (b, t1) ->
            let uu___1 = free_vars_b tvars_only env b in
            (match uu___1 with
             | (env1, f) ->
                 let uu___2 = free_vars tvars_only env1 t1 in
                 FStar_Compiler_List.op_At f uu___2)
        | FStar_Parser_AST.Sum (binders, body) ->
            let uu___1 =
              FStar_Compiler_List.fold_left
                (fun uu___2 ->
                   fun bt ->
                     match uu___2 with
                     | (env1, free) ->
                         let uu___3 =
                           match bt with
                           | FStar_Pervasives.Inl binder ->
                               free_vars_b tvars_only env1 binder
                           | FStar_Pervasives.Inr t1 ->
                               let uu___4 = free_vars tvars_only env1 t1 in
                               (env1, uu___4) in
                         (match uu___3 with
                          | (env2, f) ->
                              (env2, (FStar_Compiler_List.op_At f free))))
                (env, []) binders in
            (match uu___1 with
             | (env1, free) ->
                 let uu___2 = free_vars tvars_only env1 body in
                 FStar_Compiler_List.op_At free uu___2)
        | FStar_Parser_AST.Product (binders, body) ->
            let uu___1 = free_vars_bs tvars_only env binders in
            (match uu___1 with
             | (env1, free) ->
                 let uu___2 = free_vars tvars_only env1 body in
                 FStar_Compiler_List.op_At free uu___2)
        | FStar_Parser_AST.Project (t1, uu___1) ->
            free_vars tvars_only env t1
        | FStar_Parser_AST.Attributes cattributes ->
            FStar_Compiler_List.collect (free_vars tvars_only env)
              cattributes
        | FStar_Parser_AST.CalcProof (rel, init, steps) ->
            let uu___1 = free_vars tvars_only env rel in
            let uu___2 =
              let uu___3 = free_vars tvars_only env init in
              let uu___4 =
                FStar_Compiler_List.collect
                  (fun uu___5 ->
                     match uu___5 with
                     | FStar_Parser_AST.CalcStep (rel1, just, next) ->
                         let uu___6 = free_vars tvars_only env rel1 in
                         let uu___7 =
                           let uu___8 = free_vars tvars_only env just in
                           let uu___9 = free_vars tvars_only env next in
                           FStar_Compiler_List.op_At uu___8 uu___9 in
                         FStar_Compiler_List.op_At uu___6 uu___7) steps in
              FStar_Compiler_List.op_At uu___3 uu___4 in
            FStar_Compiler_List.op_At uu___1 uu___2
        | FStar_Parser_AST.ElimForall (bs, t1, ts) ->
            let uu___1 = free_vars_bs tvars_only env bs in
            (match uu___1 with
             | (env', free) ->
                 let uu___2 =
                   let uu___3 = free_vars tvars_only env' t1 in
                   let uu___4 =
                     FStar_Compiler_List.collect (free_vars tvars_only env')
                       ts in
                   FStar_Compiler_List.op_At uu___3 uu___4 in
                 FStar_Compiler_List.op_At free uu___2)
        | FStar_Parser_AST.ElimExists (binders, p, q, y, e) ->
            let uu___1 = free_vars_bs tvars_only env binders in
            (match uu___1 with
             | (env', free) ->
                 let uu___2 = free_vars_b tvars_only env' y in
                 (match uu___2 with
                  | (env'', free') ->
                      let uu___3 =
                        let uu___4 = free_vars tvars_only env' p in
                        let uu___5 =
                          let uu___6 = free_vars tvars_only env q in
                          let uu___7 =
                            let uu___8 = free_vars tvars_only env'' e in
                            FStar_Compiler_List.op_At free' uu___8 in
                          FStar_Compiler_List.op_At uu___6 uu___7 in
                        FStar_Compiler_List.op_At uu___4 uu___5 in
                      FStar_Compiler_List.op_At free uu___3))
        | FStar_Parser_AST.ElimImplies (p, q, e) ->
            let uu___1 = free_vars tvars_only env p in
            let uu___2 =
              let uu___3 = free_vars tvars_only env q in
              let uu___4 = free_vars tvars_only env e in
              FStar_Compiler_List.op_At uu___3 uu___4 in
            FStar_Compiler_List.op_At uu___1 uu___2
        | FStar_Parser_AST.ElimOr (p, q, r, x, e, x', e') ->
            let uu___1 = free_vars tvars_only env p in
            let uu___2 =
              let uu___3 = free_vars tvars_only env q in
              let uu___4 =
                let uu___5 = free_vars tvars_only env r in
                let uu___6 =
                  let uu___7 =
                    let uu___8 = free_vars_b tvars_only env x in
                    match uu___8 with
                    | (env', free) ->
                        let uu___9 = free_vars tvars_only env' e in
                        FStar_Compiler_List.op_At free uu___9 in
                  let uu___8 =
                    let uu___9 = free_vars_b tvars_only env x' in
                    match uu___9 with
                    | (env', free) ->
                        let uu___10 = free_vars tvars_only env' e' in
                        FStar_Compiler_List.op_At free uu___10 in
                  FStar_Compiler_List.op_At uu___7 uu___8 in
                FStar_Compiler_List.op_At uu___5 uu___6 in
              FStar_Compiler_List.op_At uu___3 uu___4 in
            FStar_Compiler_List.op_At uu___1 uu___2
        | FStar_Parser_AST.ElimAnd (p, q, r, x, y, e) ->
            let uu___1 = free_vars tvars_only env p in
            let uu___2 =
              let uu___3 = free_vars tvars_only env q in
              let uu___4 =
                let uu___5 = free_vars tvars_only env r in
                let uu___6 =
                  let uu___7 = free_vars_bs tvars_only env [x; y] in
                  match uu___7 with
                  | (env', free) ->
                      let uu___8 = free_vars tvars_only env' e in
                      FStar_Compiler_List.op_At free uu___8 in
                FStar_Compiler_List.op_At uu___5 uu___6 in
              FStar_Compiler_List.op_At uu___3 uu___4 in
            FStar_Compiler_List.op_At uu___1 uu___2
        | FStar_Parser_AST.ListLiteral ts ->
            FStar_Compiler_List.collect (free_vars tvars_only env) ts
        | FStar_Parser_AST.SeqLiteral ts ->
            FStar_Compiler_List.collect (free_vars tvars_only env) ts
        | FStar_Parser_AST.Abs uu___1 -> []
        | FStar_Parser_AST.Function uu___1 -> []
        | FStar_Parser_AST.Let uu___1 -> []
        | FStar_Parser_AST.LetOpen uu___1 -> []
        | FStar_Parser_AST.If uu___1 -> []
        | FStar_Parser_AST.QForall uu___1 -> []
        | FStar_Parser_AST.QExists uu___1 -> []
        | FStar_Parser_AST.QuantOp uu___1 -> []
        | FStar_Parser_AST.Record uu___1 -> []
        | FStar_Parser_AST.Match uu___1 -> []
        | FStar_Parser_AST.TryWith uu___1 -> []
        | FStar_Parser_AST.Bind uu___1 -> []
        | FStar_Parser_AST.Quote uu___1 -> []
        | FStar_Parser_AST.VQuote uu___1 -> []
        | FStar_Parser_AST.Antiquote uu___1 -> []
        | FStar_Parser_AST.Seq uu___1 -> []
let (free_type_vars :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.term -> FStar_Ident.ident Prims.list)
  = free_vars true
let (head_and_args :
  FStar_Parser_AST.term ->
    (FStar_Parser_AST.term * (FStar_Parser_AST.term * FStar_Parser_AST.imp)
      Prims.list))
  =
  fun t ->
    let rec aux args t1 =
      let uu___ = let uu___1 = unparen t1 in uu___1.FStar_Parser_AST.tm in
      match uu___ with
      | FStar_Parser_AST.App (t2, arg, imp) -> aux ((arg, imp) :: args) t2
      | FStar_Parser_AST.Construct (l, args') ->
          ({
             FStar_Parser_AST.tm = (FStar_Parser_AST.Name l);
             FStar_Parser_AST.range = (t1.FStar_Parser_AST.range);
             FStar_Parser_AST.level = (t1.FStar_Parser_AST.level)
           }, (FStar_Compiler_List.op_At args' args))
      | uu___1 -> (t1, args) in
    aux [] t
let (close :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun env ->
    fun t ->
      let ftv = let uu___ = free_type_vars env t in sort_ftv uu___ in
      if (FStar_Compiler_List.length ftv) = Prims.int_zero
      then t
      else
        (let binders =
           FStar_Compiler_List.map
             (fun x ->
                let uu___1 =
                  let uu___2 =
                    let uu___3 =
                      let uu___4 = FStar_Ident.range_of_id x in
                      tm_type uu___4 in
                    (x, uu___3) in
                  FStar_Parser_AST.TAnnotated uu___2 in
                let uu___2 = FStar_Ident.range_of_id x in
                FStar_Parser_AST.mk_binder uu___1 uu___2
                  FStar_Parser_AST.Type_level
                  (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit))
             ftv in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t))
             t.FStar_Parser_AST.range t.FStar_Parser_AST.level in
         result)
let (close_fun :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Parser_AST.term) =
  fun env ->
    fun t ->
      let ftv = let uu___ = free_type_vars env t in sort_ftv uu___ in
      if (FStar_Compiler_List.length ftv) = Prims.int_zero
      then t
      else
        (let binders =
           FStar_Compiler_List.map
             (fun x ->
                let uu___1 =
                  let uu___2 =
                    let uu___3 =
                      let uu___4 = FStar_Ident.range_of_id x in
                      tm_type uu___4 in
                    (x, uu___3) in
                  FStar_Parser_AST.TAnnotated uu___2 in
                let uu___2 = FStar_Ident.range_of_id x in
                FStar_Parser_AST.mk_binder uu___1 uu___2
                  FStar_Parser_AST.Type_level
                  (FStar_Pervasives_Native.Some FStar_Parser_AST.Implicit))
             ftv in
         let t1 =
           let uu___1 = let uu___2 = unparen t in uu___2.FStar_Parser_AST.tm in
           match uu___1 with
           | FStar_Parser_AST.Product uu___2 -> t
           | uu___2 ->
               let uu___3 =
                 let uu___4 =
                   let uu___5 =
                     FStar_Parser_AST.mk_term
                       (FStar_Parser_AST.Name
                          FStar_Parser_Const.effect_Tot_lid)
                       t.FStar_Parser_AST.range t.FStar_Parser_AST.level in
                   (uu___5, t, FStar_Parser_AST.Nothing) in
                 FStar_Parser_AST.App uu___4 in
               FStar_Parser_AST.mk_term uu___3 t.FStar_Parser_AST.range
                 t.FStar_Parser_AST.level in
         let result =
           FStar_Parser_AST.mk_term (FStar_Parser_AST.Product (binders, t1))
             t1.FStar_Parser_AST.range t1.FStar_Parser_AST.level in
         result)
let rec (uncurry :
  FStar_Parser_AST.binder Prims.list ->
    FStar_Parser_AST.term ->
      (FStar_Parser_AST.binder Prims.list * FStar_Parser_AST.term))
  =
  fun bs ->
    fun t ->
      match t.FStar_Parser_AST.tm with
      | FStar_Parser_AST.Product (binders, t1) ->
          uncurry (FStar_Compiler_List.op_At bs binders) t1
      | uu___ -> (bs, t)
let rec (is_var_pattern : FStar_Parser_AST.pattern -> Prims.bool) =
  fun p ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatWild uu___ -> true
    | FStar_Parser_AST.PatTvar uu___ -> true
    | FStar_Parser_AST.PatVar uu___ -> true
    | FStar_Parser_AST.PatAscribed (p1, uu___) -> is_var_pattern p1
    | uu___ -> false
let rec (is_app_pattern : FStar_Parser_AST.pattern -> Prims.bool) =
  fun p ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatAscribed (p1, uu___) -> is_app_pattern p1
    | FStar_Parser_AST.PatApp
        ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar uu___;
           FStar_Parser_AST.prange = uu___1;_},
         uu___2)
        -> true
    | uu___ -> false
let (replace_unit_pattern :
  FStar_Parser_AST.pattern -> FStar_Parser_AST.pattern) =
  fun p ->
    match p.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatConst (FStar_Const.Const_unit) ->
        let uu___ =
          let uu___1 =
            let uu___2 =
              FStar_Parser_AST.mk_pattern
                (FStar_Parser_AST.PatWild (FStar_Pervasives_Native.None, []))
                p.FStar_Parser_AST.prange in
            let uu___3 =
              let uu___4 = unit_ty p.FStar_Parser_AST.prange in
              (uu___4, FStar_Pervasives_Native.None) in
            (uu___2, uu___3) in
          FStar_Parser_AST.PatAscribed uu___1 in
        FStar_Parser_AST.mk_pattern uu___ p.FStar_Parser_AST.prange
    | uu___ -> p
let rec (destruct_app_pattern :
  env_t ->
    Prims.bool ->
      FStar_Parser_AST.pattern ->
        ((FStar_Ident.ident, FStar_Ident.lid) FStar_Pervasives.either *
          FStar_Parser_AST.pattern Prims.list * (FStar_Parser_AST.term *
          FStar_Parser_AST.term FStar_Pervasives_Native.option)
          FStar_Pervasives_Native.option))
  =
  fun env ->
    fun is_top_level ->
      fun p ->
        match p.FStar_Parser_AST.pat with
        | FStar_Parser_AST.PatAscribed (p1, t) ->
            let uu___ = destruct_app_pattern env is_top_level p1 in
            (match uu___ with
             | (name, args, uu___1) ->
                 (name, args, (FStar_Pervasives_Native.Some t)))
        | FStar_Parser_AST.PatApp
            ({
               FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                 (id, uu___, uu___1);
               FStar_Parser_AST.prange = uu___2;_},
             args)
            when is_top_level ->
            let uu___3 =
              let uu___4 = FStar_Syntax_DsEnv.qualify env id in
              FStar_Pervasives.Inr uu___4 in
            (uu___3, args, FStar_Pervasives_Native.None)
        | FStar_Parser_AST.PatApp
            ({
               FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                 (id, uu___, uu___1);
               FStar_Parser_AST.prange = uu___2;_},
             args)
            ->
            ((FStar_Pervasives.Inl id), args, FStar_Pervasives_Native.None)
        | uu___ -> FStar_Compiler_Effect.failwith "Not an app pattern"
let rec (gather_pattern_bound_vars_maybe_top :
  FStar_Ident.ident FStar_Compiler_FlatSet.t ->
    FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Compiler_FlatSet.t)
  =
  fun uu___1 ->
    fun uu___ ->
      (fun acc ->
         fun p ->
           let gather_pattern_bound_vars_from_list =
             FStar_Compiler_List.fold_left
               gather_pattern_bound_vars_maybe_top acc in
           match p.FStar_Parser_AST.pat with
           | FStar_Parser_AST.PatWild uu___ -> Obj.magic (Obj.repr acc)
           | FStar_Parser_AST.PatConst uu___ -> Obj.magic (Obj.repr acc)
           | FStar_Parser_AST.PatVQuote uu___ -> Obj.magic (Obj.repr acc)
           | FStar_Parser_AST.PatName uu___ -> Obj.magic (Obj.repr acc)
           | FStar_Parser_AST.PatOp uu___ -> Obj.magic (Obj.repr acc)
           | FStar_Parser_AST.PatApp (phead, pats) ->
               Obj.magic
                 (Obj.repr
                    (gather_pattern_bound_vars_from_list (phead :: pats)))
           | FStar_Parser_AST.PatTvar (x, uu___, uu___1) ->
               Obj.magic
                 (Obj.repr
                    (FStar_Class_Setlike.add ()
                       (Obj.magic
                          (FStar_Compiler_FlatSet.setlike_flat_set
                             FStar_Syntax_Syntax.ord_ident)) x
                       (Obj.magic acc)))
           | FStar_Parser_AST.PatVar (x, uu___, uu___1) ->
               Obj.magic
                 (Obj.repr
                    (FStar_Class_Setlike.add ()
                       (Obj.magic
                          (FStar_Compiler_FlatSet.setlike_flat_set
                             FStar_Syntax_Syntax.ord_ident)) x
                       (Obj.magic acc)))
           | FStar_Parser_AST.PatList pats ->
               Obj.magic
                 (Obj.repr (gather_pattern_bound_vars_from_list pats))
           | FStar_Parser_AST.PatTuple (pats, uu___) ->
               Obj.magic
                 (Obj.repr (gather_pattern_bound_vars_from_list pats))
           | FStar_Parser_AST.PatOr pats ->
               Obj.magic
                 (Obj.repr (gather_pattern_bound_vars_from_list pats))
           | FStar_Parser_AST.PatRecord guarded_pats ->
               Obj.magic
                 (Obj.repr
                    (let uu___ =
                       FStar_Compiler_List.map FStar_Pervasives_Native.snd
                         guarded_pats in
                     gather_pattern_bound_vars_from_list uu___))
           | FStar_Parser_AST.PatAscribed (pat, uu___) ->
               Obj.magic
                 (Obj.repr (gather_pattern_bound_vars_maybe_top acc pat)))
        uu___1 uu___
let (gather_pattern_bound_vars :
  FStar_Parser_AST.pattern -> FStar_Ident.ident FStar_Compiler_FlatSet.t) =
  let acc =
    Obj.magic
      (FStar_Class_Setlike.empty ()
         (Obj.magic
            (FStar_Compiler_FlatSet.setlike_flat_set
               FStar_Syntax_Syntax.ord_ident)) ()) in
  fun p -> gather_pattern_bound_vars_maybe_top acc p
type bnd =
  | LocalBinder of (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.bqual *
  FStar_Syntax_Syntax.term Prims.list) 
  | LetBinder of (FStar_Ident.lident * (FStar_Syntax_Syntax.term *
  FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)) 
let (uu___is_LocalBinder : bnd -> Prims.bool) =
  fun projectee ->
    match projectee with | LocalBinder _0 -> true | uu___ -> false
let (__proj__LocalBinder__item___0 :
  bnd ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.bqual *
      FStar_Syntax_Syntax.term Prims.list))
  = fun projectee -> match projectee with | LocalBinder _0 -> _0
let (uu___is_LetBinder : bnd -> Prims.bool) =
  fun projectee ->
    match projectee with | LetBinder _0 -> true | uu___ -> false
let (__proj__LetBinder__item___0 :
  bnd ->
    (FStar_Ident.lident * (FStar_Syntax_Syntax.term *
      FStar_Syntax_Syntax.term FStar_Pervasives_Native.option)))
  = fun projectee -> match projectee with | LetBinder _0 -> _0
let (is_implicit : bnd -> Prims.bool) =
  fun b ->
    match b with
    | LocalBinder
        (uu___, FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Implicit
         uu___1), uu___2)
        -> true
    | uu___ -> false
let (binder_of_bnd :
  bnd ->
    (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.bqual *
      FStar_Syntax_Syntax.term Prims.list))
  =
  fun uu___ ->
    match uu___ with
    | LocalBinder (a, aq, attrs) -> (a, aq, attrs)
    | uu___1 -> FStar_Compiler_Effect.failwith "Impossible"
let (mk_lb :
  (FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax Prims.list *
    (FStar_Syntax_Syntax.bv, FStar_Syntax_Syntax.fv) FStar_Pervasives.either
    * FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax *
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax *
    FStar_Compiler_Range_Type.range) -> FStar_Syntax_Syntax.letbinding)
  =
  fun uu___ ->
    match uu___ with
    | (attrs, n, t, e, pos) ->
        let uu___1 = FStar_Parser_Const.effect_ALL_lid () in
        {
          FStar_Syntax_Syntax.lbname = n;
          FStar_Syntax_Syntax.lbunivs = [];
          FStar_Syntax_Syntax.lbtyp = t;
          FStar_Syntax_Syntax.lbeff = uu___1;
          FStar_Syntax_Syntax.lbdef = e;
          FStar_Syntax_Syntax.lbattrs = attrs;
          FStar_Syntax_Syntax.lbpos = pos
        }
let (no_annot_abs :
  FStar_Syntax_Syntax.binders ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax)
  =
  fun bs -> fun t -> FStar_Syntax_Util.abs bs t FStar_Pervasives_Native.None
let rec (generalize_annotated_univs :
  FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt) =
  fun s ->
    let vars = FStar_Compiler_Util.mk_ref [] in
    let seen =
      let uu___ =
        Obj.magic
          (FStar_Class_Setlike.empty ()
             (Obj.magic
                (FStar_Compiler_RBSet.setlike_rbset
                   FStar_Syntax_Syntax.ord_ident)) ()) in
      FStar_Compiler_Util.mk_ref uu___ in
    let reg u =
      let uu___ =
        let uu___1 =
          let uu___2 = FStar_Compiler_Effect.op_Bang seen in
          FStar_Class_Setlike.mem ()
            (Obj.magic
               (FStar_Compiler_RBSet.setlike_rbset
                  FStar_Syntax_Syntax.ord_ident)) u (Obj.magic uu___2) in
        Prims.op_Negation uu___1 in
      if uu___
      then
        ((let uu___2 =
            let uu___3 = FStar_Compiler_Effect.op_Bang seen in
            Obj.magic
              (FStar_Class_Setlike.add ()
                 (Obj.magic
                    (FStar_Compiler_RBSet.setlike_rbset
                       FStar_Syntax_Syntax.ord_ident)) u (Obj.magic uu___3)) in
          FStar_Compiler_Effect.op_Colon_Equals seen uu___2);
         (let uu___2 =
            let uu___3 = FStar_Compiler_Effect.op_Bang vars in u :: uu___3 in
          FStar_Compiler_Effect.op_Colon_Equals vars uu___2))
      else () in
    let get uu___ =
      let uu___1 = FStar_Compiler_Effect.op_Bang vars in
      FStar_Compiler_List.rev uu___1 in
    let uu___ =
      FStar_Syntax_Visit.visit_sigelt false (fun t -> t)
        (fun u ->
           (match u with
            | FStar_Syntax_Syntax.U_name nm -> reg nm
            | uu___3 -> ());
           u) s in
    let unames = get () in
    match s.FStar_Syntax_Syntax.sigel with
    | FStar_Syntax_Syntax.Sig_inductive_typ uu___1 ->
        FStar_Compiler_Effect.failwith
          "Impossible: collect_annotated_universes: bare data/type constructor"
    | FStar_Syntax_Syntax.Sig_datacon uu___1 ->
        FStar_Compiler_Effect.failwith
          "Impossible: collect_annotated_universes: bare data/type constructor"
    | FStar_Syntax_Syntax.Sig_bundle
        { FStar_Syntax_Syntax.ses = sigs; FStar_Syntax_Syntax.lids = lids;_}
        ->
        let usubst = FStar_Syntax_Subst.univ_var_closing unames in
        let uu___1 =
          let uu___2 =
            let uu___3 =
              FStar_Compiler_List.map
                (fun se ->
                   match se.FStar_Syntax_Syntax.sigel with
                   | FStar_Syntax_Syntax.Sig_inductive_typ
                       { FStar_Syntax_Syntax.lid = lid;
                         FStar_Syntax_Syntax.us = uu___4;
                         FStar_Syntax_Syntax.params = bs;
                         FStar_Syntax_Syntax.num_uniform_params = num_uniform;
                         FStar_Syntax_Syntax.t = t;
                         FStar_Syntax_Syntax.mutuals = lids1;
                         FStar_Syntax_Syntax.ds = lids2;
                         FStar_Syntax_Syntax.injective_type_params = uu___5;_}
                       ->
                       let uu___6 =
                         let uu___7 =
                           let uu___8 =
                             FStar_Syntax_Subst.subst_binders usubst bs in
                           let uu___9 =
                             let uu___10 =
                               FStar_Syntax_Subst.shift_subst
                                 (FStar_Compiler_List.length bs) usubst in
                             FStar_Syntax_Subst.subst uu___10 t in
                           {
                             FStar_Syntax_Syntax.lid = lid;
                             FStar_Syntax_Syntax.us = unames;
                             FStar_Syntax_Syntax.params = uu___8;
                             FStar_Syntax_Syntax.num_uniform_params =
                               num_uniform;
                             FStar_Syntax_Syntax.t = uu___9;
                             FStar_Syntax_Syntax.mutuals = lids1;
                             FStar_Syntax_Syntax.ds = lids2;
                             FStar_Syntax_Syntax.injective_type_params =
                               false
                           } in
                         FStar_Syntax_Syntax.Sig_inductive_typ uu___7 in
                       {
                         FStar_Syntax_Syntax.sigel = uu___6;
                         FStar_Syntax_Syntax.sigrng =
                           (se.FStar_Syntax_Syntax.sigrng);
                         FStar_Syntax_Syntax.sigquals =
                           (se.FStar_Syntax_Syntax.sigquals);
                         FStar_Syntax_Syntax.sigmeta =
                           (se.FStar_Syntax_Syntax.sigmeta);
                         FStar_Syntax_Syntax.sigattrs =
                           (se.FStar_Syntax_Syntax.sigattrs);
                         FStar_Syntax_Syntax.sigopens_and_abbrevs =
                           (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                         FStar_Syntax_Syntax.sigopts =
                           (se.FStar_Syntax_Syntax.sigopts)
                       }
                   | FStar_Syntax_Syntax.Sig_datacon
                       { FStar_Syntax_Syntax.lid1 = lid;
                         FStar_Syntax_Syntax.us1 = uu___4;
                         FStar_Syntax_Syntax.t1 = t;
                         FStar_Syntax_Syntax.ty_lid = tlid;
                         FStar_Syntax_Syntax.num_ty_params = n;
                         FStar_Syntax_Syntax.mutuals1 = lids1;
                         FStar_Syntax_Syntax.injective_type_params1 = uu___5;_}
                       ->
                       let uu___6 =
                         let uu___7 =
                           let uu___8 = FStar_Syntax_Subst.subst usubst t in
                           {
                             FStar_Syntax_Syntax.lid1 = lid;
                             FStar_Syntax_Syntax.us1 = unames;
                             FStar_Syntax_Syntax.t1 = uu___8;
                             FStar_Syntax_Syntax.ty_lid = tlid;
                             FStar_Syntax_Syntax.num_ty_params = n;
                             FStar_Syntax_Syntax.mutuals1 = lids1;
                             FStar_Syntax_Syntax.injective_type_params1 =
                               false
                           } in
                         FStar_Syntax_Syntax.Sig_datacon uu___7 in
                       {
                         FStar_Syntax_Syntax.sigel = uu___6;
                         FStar_Syntax_Syntax.sigrng =
                           (se.FStar_Syntax_Syntax.sigrng);
                         FStar_Syntax_Syntax.sigquals =
                           (se.FStar_Syntax_Syntax.sigquals);
                         FStar_Syntax_Syntax.sigmeta =
                           (se.FStar_Syntax_Syntax.sigmeta);
                         FStar_Syntax_Syntax.sigattrs =
                           (se.FStar_Syntax_Syntax.sigattrs);
                         FStar_Syntax_Syntax.sigopens_and_abbrevs =
                           (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                         FStar_Syntax_Syntax.sigopts =
                           (se.FStar_Syntax_Syntax.sigopts)
                       }
                   | uu___4 ->
                       FStar_Compiler_Effect.failwith
                         "Impossible: collect_annotated_universes: Sig_bundle should not have a non data/type sigelt")
                sigs in
            {
              FStar_Syntax_Syntax.ses = uu___3;
              FStar_Syntax_Syntax.lids = lids
            } in
          FStar_Syntax_Syntax.Sig_bundle uu___2 in
        {
          FStar_Syntax_Syntax.sigel = uu___1;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_declare_typ
        { FStar_Syntax_Syntax.lid2 = lid; FStar_Syntax_Syntax.us2 = uu___1;
          FStar_Syntax_Syntax.t2 = t;_}
        ->
        let uu___2 =
          let uu___3 =
            let uu___4 = FStar_Syntax_Subst.close_univ_vars unames t in
            {
              FStar_Syntax_Syntax.lid2 = lid;
              FStar_Syntax_Syntax.us2 = unames;
              FStar_Syntax_Syntax.t2 = uu___4
            } in
          FStar_Syntax_Syntax.Sig_declare_typ uu___3 in
        {
          FStar_Syntax_Syntax.sigel = uu___2;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_let
        { FStar_Syntax_Syntax.lbs1 = (b, lbs);
          FStar_Syntax_Syntax.lids1 = lids;_}
        ->
        let usubst = FStar_Syntax_Subst.univ_var_closing unames in
        let uu___1 =
          let uu___2 =
            let uu___3 =
              let uu___4 =
                FStar_Compiler_List.map
                  (fun lb ->
                     let uu___5 =
                       FStar_Syntax_Subst.subst usubst
                         lb.FStar_Syntax_Syntax.lbtyp in
                     let uu___6 =
                       FStar_Syntax_Subst.subst usubst
                         lb.FStar_Syntax_Syntax.lbdef in
                     {
                       FStar_Syntax_Syntax.lbname =
                         (lb.FStar_Syntax_Syntax.lbname);
                       FStar_Syntax_Syntax.lbunivs = unames;
                       FStar_Syntax_Syntax.lbtyp = uu___5;
                       FStar_Syntax_Syntax.lbeff =
                         (lb.FStar_Syntax_Syntax.lbeff);
                       FStar_Syntax_Syntax.lbdef = uu___6;
                       FStar_Syntax_Syntax.lbattrs =
                         (lb.FStar_Syntax_Syntax.lbattrs);
                       FStar_Syntax_Syntax.lbpos =
                         (lb.FStar_Syntax_Syntax.lbpos)
                     }) lbs in
              (b, uu___4) in
            {
              FStar_Syntax_Syntax.lbs1 = uu___3;
              FStar_Syntax_Syntax.lids1 = lids
            } in
          FStar_Syntax_Syntax.Sig_let uu___2 in
        {
          FStar_Syntax_Syntax.sigel = uu___1;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_assume
        { FStar_Syntax_Syntax.lid3 = lid; FStar_Syntax_Syntax.us3 = uu___1;
          FStar_Syntax_Syntax.phi1 = fml;_}
        ->
        let uu___2 =
          let uu___3 =
            let uu___4 = FStar_Syntax_Subst.close_univ_vars unames fml in
            {
              FStar_Syntax_Syntax.lid3 = lid;
              FStar_Syntax_Syntax.us3 = unames;
              FStar_Syntax_Syntax.phi1 = uu___4
            } in
          FStar_Syntax_Syntax.Sig_assume uu___3 in
        {
          FStar_Syntax_Syntax.sigel = uu___2;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_effect_abbrev
        { FStar_Syntax_Syntax.lid4 = lid; FStar_Syntax_Syntax.us4 = uu___1;
          FStar_Syntax_Syntax.bs2 = bs; FStar_Syntax_Syntax.comp1 = c;
          FStar_Syntax_Syntax.cflags = flags;_}
        ->
        let usubst = FStar_Syntax_Subst.univ_var_closing unames in
        let uu___2 =
          let uu___3 =
            let uu___4 = FStar_Syntax_Subst.subst_binders usubst bs in
            let uu___5 = FStar_Syntax_Subst.subst_comp usubst c in
            {
              FStar_Syntax_Syntax.lid4 = lid;
              FStar_Syntax_Syntax.us4 = unames;
              FStar_Syntax_Syntax.bs2 = uu___4;
              FStar_Syntax_Syntax.comp1 = uu___5;
              FStar_Syntax_Syntax.cflags = flags
            } in
          FStar_Syntax_Syntax.Sig_effect_abbrev uu___3 in
        {
          FStar_Syntax_Syntax.sigel = uu___2;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_fail
        { FStar_Syntax_Syntax.errs = errs;
          FStar_Syntax_Syntax.fail_in_lax = lax;
          FStar_Syntax_Syntax.ses1 = ses;_}
        ->
        let uu___1 =
          let uu___2 =
            let uu___3 =
              FStar_Compiler_List.map generalize_annotated_univs ses in
            {
              FStar_Syntax_Syntax.errs = errs;
              FStar_Syntax_Syntax.fail_in_lax = lax;
              FStar_Syntax_Syntax.ses1 = uu___3
            } in
          FStar_Syntax_Syntax.Sig_fail uu___2 in
        {
          FStar_Syntax_Syntax.sigel = uu___1;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_new_effect ed ->
        let generalize_annotated_univs_signature s1 =
          match s1 with
          | FStar_Syntax_Syntax.Layered_eff_sig (n, (uu___1, t)) ->
              let uvs =
                let uu___2 = FStar_Syntax_Free.univnames t in
                FStar_Class_Setlike.elems ()
                  (Obj.magic
                     (FStar_Compiler_FlatSet.setlike_flat_set
                        FStar_Syntax_Syntax.ord_ident)) (Obj.magic uu___2) in
              let usubst = FStar_Syntax_Subst.univ_var_closing uvs in
              let uu___2 =
                let uu___3 =
                  let uu___4 = FStar_Syntax_Subst.subst usubst t in
                  (uvs, uu___4) in
                (n, uu___3) in
              FStar_Syntax_Syntax.Layered_eff_sig uu___2
          | FStar_Syntax_Syntax.WP_eff_sig (uu___1, t) ->
              let uvs =
                let uu___2 = FStar_Syntax_Free.univnames t in
                FStar_Class_Setlike.elems ()
                  (Obj.magic
                     (FStar_Compiler_FlatSet.setlike_flat_set
                        FStar_Syntax_Syntax.ord_ident)) (Obj.magic uu___2) in
              let usubst = FStar_Syntax_Subst.univ_var_closing uvs in
              let uu___2 =
                let uu___3 = FStar_Syntax_Subst.subst usubst t in
                (uvs, uu___3) in
              FStar_Syntax_Syntax.WP_eff_sig uu___2 in
        let uu___1 =
          let uu___2 =
            let uu___3 =
              generalize_annotated_univs_signature
                ed.FStar_Syntax_Syntax.signature in
            {
              FStar_Syntax_Syntax.mname = (ed.FStar_Syntax_Syntax.mname);
              FStar_Syntax_Syntax.cattributes =
                (ed.FStar_Syntax_Syntax.cattributes);
              FStar_Syntax_Syntax.univs = (ed.FStar_Syntax_Syntax.univs);
              FStar_Syntax_Syntax.binders = (ed.FStar_Syntax_Syntax.binders);
              FStar_Syntax_Syntax.signature = uu___3;
              FStar_Syntax_Syntax.combinators =
                (ed.FStar_Syntax_Syntax.combinators);
              FStar_Syntax_Syntax.actions = (ed.FStar_Syntax_Syntax.actions);
              FStar_Syntax_Syntax.eff_attrs =
                (ed.FStar_Syntax_Syntax.eff_attrs);
              FStar_Syntax_Syntax.extraction_mode =
                (ed.FStar_Syntax_Syntax.extraction_mode)
            } in
          FStar_Syntax_Syntax.Sig_new_effect uu___2 in
        {
          FStar_Syntax_Syntax.sigel = uu___1;
          FStar_Syntax_Syntax.sigrng = (s.FStar_Syntax_Syntax.sigrng);
          FStar_Syntax_Syntax.sigquals = (s.FStar_Syntax_Syntax.sigquals);
          FStar_Syntax_Syntax.sigmeta = (s.FStar_Syntax_Syntax.sigmeta);
          FStar_Syntax_Syntax.sigattrs = (s.FStar_Syntax_Syntax.sigattrs);
          FStar_Syntax_Syntax.sigopens_and_abbrevs =
            (s.FStar_Syntax_Syntax.sigopens_and_abbrevs);
          FStar_Syntax_Syntax.sigopts = (s.FStar_Syntax_Syntax.sigopts)
        }
    | FStar_Syntax_Syntax.Sig_sub_effect uu___1 -> s
    | FStar_Syntax_Syntax.Sig_polymonadic_bind uu___1 -> s
    | FStar_Syntax_Syntax.Sig_polymonadic_subcomp uu___1 -> s
    | FStar_Syntax_Syntax.Sig_splice uu___1 -> s
    | FStar_Syntax_Syntax.Sig_pragma uu___1 -> s
let (is_special_effect_combinator : Prims.string -> Prims.bool) =
  fun uu___ ->
    match uu___ with
    | "lift1" -> true
    | "lift2" -> true
    | "pure" -> true
    | "app" -> true
    | "push" -> true
    | "wp_if_then_else" -> true
    | "wp_assert" -> true
    | "wp_assume" -> true
    | "wp_close" -> true
    | "stronger" -> true
    | "ite_wp" -> true
    | "wp_trivial" -> true
    | "ctx" -> true
    | "gctx" -> true
    | "lift_from_pure" -> true
    | "return_wp" -> true
    | "return_elab" -> true
    | "bind_wp" -> true
    | "bind_elab" -> true
    | "repr" -> true
    | "post" -> true
    | "pre" -> true
    | "wp" -> true
    | uu___1 -> false
let rec (sum_to_universe :
  FStar_Syntax_Syntax.universe -> Prims.int -> FStar_Syntax_Syntax.universe)
  =
  fun u ->
    fun n ->
      if n = Prims.int_zero
      then u
      else
        (let uu___1 = sum_to_universe u (n - Prims.int_one) in
         FStar_Syntax_Syntax.U_succ uu___1)
let (int_to_universe : Prims.int -> FStar_Syntax_Syntax.universe) =
  fun n -> sum_to_universe FStar_Syntax_Syntax.U_zero n
let rec (desugar_maybe_non_constant_universe :
  FStar_Parser_AST.term ->
    (Prims.int, FStar_Syntax_Syntax.universe) FStar_Pervasives.either)
  =
  fun t ->
    let uu___ = let uu___1 = unparen t in uu___1.FStar_Parser_AST.tm in
    match uu___ with
    | FStar_Parser_AST.Wild ->
        FStar_Pervasives.Inr FStar_Syntax_Syntax.U_unknown
    | FStar_Parser_AST.Uvar u ->
        FStar_Pervasives.Inr (FStar_Syntax_Syntax.U_name u)
    | FStar_Parser_AST.Const (FStar_Const.Const_int (repr, uu___1)) ->
        let n = FStar_Compiler_Util.int_of_string repr in
        (if n < Prims.int_zero
         then
           FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t
             FStar_Errors_Codes.Fatal_NegativeUniverseConstFatal_NotSupported
             () (Obj.magic FStar_Errors_Msg.is_error_message_string)
             (Obj.magic
                (Prims.strcat
                   "Negative universe constant  are not supported : " repr))
         else ();
         FStar_Pervasives.Inl n)
    | FStar_Parser_AST.Op (op_plus, t1::t2::[]) ->
        let u1 = desugar_maybe_non_constant_universe t1 in
        let u2 = desugar_maybe_non_constant_universe t2 in
        (match (u1, u2) with
         | (FStar_Pervasives.Inl n1, FStar_Pervasives.Inl n2) ->
             FStar_Pervasives.Inl (n1 + n2)
         | (FStar_Pervasives.Inl n, FStar_Pervasives.Inr u) ->
             let uu___2 = sum_to_universe u n in FStar_Pervasives.Inr uu___2
         | (FStar_Pervasives.Inr u, FStar_Pervasives.Inl n) ->
             let uu___2 = sum_to_universe u n in FStar_Pervasives.Inr uu___2
         | (FStar_Pervasives.Inr u11, FStar_Pervasives.Inr u21) ->
             let uu___2 =
               let uu___3 =
                 FStar_Class_Show.show FStar_Parser_AST.showable_term t in
               Prims.strcat
                 "This universe might contain a sum of two universe variables "
                 uu___3 in
             FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t
               FStar_Errors_Codes.Fatal_UniverseMightContainSumOfTwoUnivVars
               () (Obj.magic FStar_Errors_Msg.is_error_message_string)
               (Obj.magic uu___2))
    | FStar_Parser_AST.App uu___1 ->
        let rec aux t1 univargs =
          let uu___2 = let uu___3 = unparen t1 in uu___3.FStar_Parser_AST.tm in
          match uu___2 with
          | FStar_Parser_AST.App (t2, targ, uu___3) ->
              let uarg = desugar_maybe_non_constant_universe targ in
              aux t2 (uarg :: univargs)
          | FStar_Parser_AST.Var max_lid ->
              let uu___4 =
                FStar_Compiler_List.existsb
                  (fun uu___5 ->
                     match uu___5 with
                     | FStar_Pervasives.Inr uu___6 -> true
                     | uu___6 -> false) univargs in
              if uu___4
              then
                let uu___5 =
                  let uu___6 =
                    FStar_Compiler_List.map
                      (fun uu___7 ->
                         match uu___7 with
                         | FStar_Pervasives.Inl n -> int_to_universe n
                         | FStar_Pervasives.Inr u -> u) univargs in
                  FStar_Syntax_Syntax.U_max uu___6 in
                FStar_Pervasives.Inr uu___5
              else
                (let nargs =
                   FStar_Compiler_List.map
                     (fun uu___6 ->
                        match uu___6 with
                        | FStar_Pervasives.Inl n -> n
                        | FStar_Pervasives.Inr uu___7 ->
                            FStar_Compiler_Effect.failwith "impossible")
                     univargs in
                 let uu___6 =
                   FStar_Compiler_List.fold_left
                     (fun m -> fun n -> if m > n then m else n)
                     Prims.int_zero nargs in
                 FStar_Pervasives.Inl uu___6)
          | uu___3 ->
              let uu___4 =
                let uu___5 =
                  let uu___6 = FStar_Parser_AST.term_to_string t1 in
                  Prims.strcat uu___6 " in universe context" in
                Prims.strcat "Unexpected term " uu___5 in
              FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t1
                FStar_Errors_Codes.Fatal_UnexpectedTermInUniverse ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic uu___4) in
        aux t []
    | uu___1 ->
        let uu___2 =
          let uu___3 =
            let uu___4 = FStar_Parser_AST.term_to_string t in
            Prims.strcat uu___4 " in universe context" in
          Prims.strcat "Unexpected term " uu___3 in
        FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t
          FStar_Errors_Codes.Fatal_UnexpectedTermInUniverse ()
          (Obj.magic FStar_Errors_Msg.is_error_message_string)
          (Obj.magic uu___2)
let (desugar_universe :
  FStar_Parser_AST.term -> FStar_Syntax_Syntax.universe) =
  fun t ->
    let u = desugar_maybe_non_constant_universe t in
    match u with
    | FStar_Pervasives.Inl n -> int_to_universe n
    | FStar_Pervasives.Inr u1 -> u1
let (check_no_aq : antiquotations_temp -> unit) =
  fun aq ->
    match aq with
    | [] -> ()
    | (bv,
       {
         FStar_Syntax_Syntax.n = FStar_Syntax_Syntax.Tm_quoted
           (e,
            { FStar_Syntax_Syntax.qkind = FStar_Syntax_Syntax.Quote_dynamic;
              FStar_Syntax_Syntax.antiquotations = uu___;_});
         FStar_Syntax_Syntax.pos = uu___1; FStar_Syntax_Syntax.vars = uu___2;
         FStar_Syntax_Syntax.hash_code = uu___3;_})::uu___4
        ->
        let uu___5 =
          let uu___6 =
            FStar_Class_Show.show FStar_Syntax_Print.showable_term e in
          FStar_Compiler_Util.format1 "Unexpected antiquotation: `@(%s)"
            uu___6 in
        FStar_Errors.raise_error (FStar_Syntax_Syntax.has_range_syntax ()) e
          FStar_Errors_Codes.Fatal_UnexpectedAntiquotation ()
          (Obj.magic FStar_Errors_Msg.is_error_message_string)
          (Obj.magic uu___5)
    | (bv, e)::uu___ ->
        let uu___1 =
          let uu___2 =
            FStar_Class_Show.show FStar_Syntax_Print.showable_term e in
          FStar_Compiler_Util.format1 "Unexpected antiquotation: `#(%s)"
            uu___2 in
        FStar_Errors.raise_error (FStar_Syntax_Syntax.has_range_syntax ()) e
          FStar_Errors_Codes.Fatal_UnexpectedAntiquotation ()
          (Obj.magic FStar_Errors_Msg.is_error_message_string)
          (Obj.magic uu___1)
let (check_linear_pattern_variables :
  FStar_Syntax_Syntax.pat' FStar_Syntax_Syntax.withinfo_t Prims.list ->
    FStar_Compiler_Range_Type.range -> unit)
  =
  fun pats ->
    fun r ->
      let rec pat_vars uu___ =
        (fun p ->
           match p.FStar_Syntax_Syntax.v with
           | FStar_Syntax_Syntax.Pat_dot_term uu___ ->
               Obj.magic
                 (Obj.repr
                    (FStar_Class_Setlike.empty ()
                       (Obj.magic
                          (FStar_Compiler_RBSet.setlike_rbset
                             FStar_Syntax_Syntax.ord_bv)) ()))
           | FStar_Syntax_Syntax.Pat_constant uu___ ->
               Obj.magic
                 (Obj.repr
                    (FStar_Class_Setlike.empty ()
                       (Obj.magic
                          (FStar_Compiler_RBSet.setlike_rbset
                             FStar_Syntax_Syntax.ord_bv)) ()))
           | FStar_Syntax_Syntax.Pat_var x ->
               Obj.magic
                 (Obj.repr
                    (let uu___ =
                       let uu___1 =
                         FStar_Ident.string_of_id
                           x.FStar_Syntax_Syntax.ppname in
                       uu___1 = FStar_Ident.reserved_prefix in
                     if uu___
                     then
                       FStar_Class_Setlike.empty ()
                         (Obj.magic
                            (FStar_Compiler_RBSet.setlike_rbset
                               FStar_Syntax_Syntax.ord_bv)) ()
                     else
                       FStar_Class_Setlike.singleton ()
                         (Obj.magic
                            (FStar_Compiler_RBSet.setlike_rbset
                               FStar_Syntax_Syntax.ord_bv)) x))
           | FStar_Syntax_Syntax.Pat_cons (uu___, uu___1, pats1) ->
               Obj.magic
                 (Obj.repr
                    (let aux uu___3 uu___2 =
                       (fun out ->
                          fun uu___2 ->
                            match uu___2 with
                            | (p1, uu___3) ->
                                let p_vars = pat_vars p1 in
                                let intersection =
                                  Obj.magic
                                    (FStar_Class_Setlike.inter ()
                                       (Obj.magic
                                          (FStar_Compiler_RBSet.setlike_rbset
                                             FStar_Syntax_Syntax.ord_bv))
                                       (Obj.magic p_vars) (Obj.magic out)) in
                                let uu___4 =
                                  FStar_Class_Setlike.is_empty ()
                                    (Obj.magic
                                       (FStar_Compiler_RBSet.setlike_rbset
                                          FStar_Syntax_Syntax.ord_bv))
                                    (Obj.magic intersection) in
                                if uu___4
                                then
                                  Obj.magic
                                    (Obj.repr
                                       (FStar_Class_Setlike.union ()
                                          (Obj.magic
                                             (FStar_Compiler_RBSet.setlike_rbset
                                                FStar_Syntax_Syntax.ord_bv))
                                          (Obj.magic out) (Obj.magic p_vars)))
                                else
                                  Obj.magic
                                    (Obj.repr
                                       (let duplicate_bv =
                                          let uu___6 =
                                            FStar_Class_Setlike.elems ()
                                              (Obj.magic
                                                 (FStar_Compiler_RBSet.setlike_rbset
                                                    FStar_Syntax_Syntax.ord_bv))
                                              (Obj.magic intersection) in
                                          FStar_Compiler_List.hd uu___6 in
                                        let uu___6 =
                                          let uu___7 =
                                            FStar_Class_Show.show
                                              FStar_Ident.showable_ident
                                              duplicate_bv.FStar_Syntax_Syntax.ppname in
                                          FStar_Compiler_Util.format1
                                            "Non-linear patterns are not permitted: `%s` appears more than once in this pattern."
                                            uu___7 in
                                        FStar_Errors.raise_error
                                          FStar_Class_HasRange.hasRange_range
                                          r
                                          FStar_Errors_Codes.Fatal_NonLinearPatternNotPermitted
                                          ()
                                          (Obj.magic
                                             FStar_Errors_Msg.is_error_message_string)
                                          (Obj.magic uu___6)))) uu___3 uu___2 in
                     let uu___2 =
                       Obj.magic
                         (FStar_Class_Setlike.empty ()
                            (Obj.magic
                               (FStar_Compiler_RBSet.setlike_rbset
                                  FStar_Syntax_Syntax.ord_bv)) ()) in
                     FStar_Compiler_List.fold_left aux uu___2 pats1))) uu___ in
      match pats with
      | [] -> ()
      | p::[] -> let uu___ = pat_vars p in ()
      | p::ps ->
          let pvars = pat_vars p in
          let aux p1 =
            let uu___ =
              let uu___1 = pat_vars p1 in
              FStar_Class_Setlike.equal ()
                (Obj.magic
                   (FStar_Compiler_RBSet.setlike_rbset
                      FStar_Syntax_Syntax.ord_bv)) (Obj.magic pvars)
                (Obj.magic uu___1) in
            if uu___
            then ()
            else
              (let symdiff uu___3 uu___2 =
                 (fun s1 ->
                    fun s2 ->
                      let uu___2 =
                        Obj.magic
                          (FStar_Class_Setlike.diff ()
                             (Obj.magic
                                (FStar_Compiler_RBSet.setlike_rbset
                                   FStar_Syntax_Syntax.ord_bv))
                             (Obj.magic s1) (Obj.magic s2)) in
                      let uu___3 =
                        Obj.magic
                          (FStar_Class_Setlike.diff ()
                             (Obj.magic
                                (FStar_Compiler_RBSet.setlike_rbset
                                   FStar_Syntax_Syntax.ord_bv))
                             (Obj.magic s2) (Obj.magic s1)) in
                      Obj.magic
                        (FStar_Class_Setlike.union ()
                           (Obj.magic
                              (FStar_Compiler_RBSet.setlike_rbset
                                 FStar_Syntax_Syntax.ord_bv))
                           (Obj.magic uu___2) (Obj.magic uu___3))) uu___3
                   uu___2 in
               let nonlinear_vars =
                 let uu___2 = pat_vars p1 in symdiff pvars uu___2 in
               let first_nonlinear_var =
                 let uu___2 =
                   FStar_Class_Setlike.elems ()
                     (Obj.magic
                        (FStar_Compiler_RBSet.setlike_rbset
                           FStar_Syntax_Syntax.ord_bv))
                     (Obj.magic nonlinear_vars) in
                 FStar_Compiler_List.hd uu___2 in
               let uu___2 =
                 let uu___3 =
                   FStar_Class_Show.show FStar_Ident.showable_ident
                     first_nonlinear_var.FStar_Syntax_Syntax.ppname in
                 FStar_Compiler_Util.format1
                   "Patterns in this match are incoherent, variable %s is bound in some but not all patterns."
                   uu___3 in
               FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
                 FStar_Errors_Codes.Fatal_IncoherentPatterns ()
                 (Obj.magic FStar_Errors_Msg.is_error_message_string)
                 (Obj.magic uu___2)) in
          FStar_Compiler_List.iter aux ps
let (smt_pat_lid : FStar_Compiler_Range_Type.range -> FStar_Ident.lident) =
  fun r -> FStar_Ident.set_lid_range FStar_Parser_Const.smtpat_lid r
let (smt_pat_or_lid : FStar_Compiler_Range_Type.range -> FStar_Ident.lident)
  = fun r -> FStar_Ident.set_lid_range FStar_Parser_Const.smtpatOr_lid r
let rec (hoist_pat_ascription' :
  FStar_Parser_AST.pattern ->
    (FStar_Parser_AST.pattern * FStar_Parser_AST.term
      FStar_Pervasives_Native.option))
  =
  fun pat ->
    let mk tm =
      FStar_Parser_AST.mk_term tm pat.FStar_Parser_AST.prange
        FStar_Parser_AST.Type_level in
    let handle_list type_lid pat_cons pats =
      let uu___ =
        let uu___1 = FStar_Compiler_List.map hoist_pat_ascription' pats in
        FStar_Compiler_List.unzip uu___1 in
      match uu___ with
      | (pats1, terms) ->
          let uu___1 =
            FStar_Compiler_List.for_all FStar_Pervasives_Native.uu___is_None
              terms in
          if uu___1
          then (pat, FStar_Pervasives_Native.None)
          else
            (let terms1 =
               FStar_Compiler_List.map
                 (fun uu___3 ->
                    match uu___3 with
                    | FStar_Pervasives_Native.Some t -> t
                    | FStar_Pervasives_Native.None ->
                        mk FStar_Parser_AST.Wild) terms in
             let uu___3 =
               let uu___4 = pat_cons pats1 in
               {
                 FStar_Parser_AST.pat = uu___4;
                 FStar_Parser_AST.prange = (pat.FStar_Parser_AST.prange)
               } in
             let uu___4 =
               let uu___5 =
                 let uu___6 = mk type_lid in
                 let uu___7 =
                   FStar_Compiler_List.map
                     (fun t -> (t, FStar_Parser_AST.Nothing)) terms1 in
                 FStar_Parser_AST.mkApp uu___6 uu___7
                   pat.FStar_Parser_AST.prange in
               FStar_Pervasives_Native.Some uu___5 in
             (uu___3, uu___4)) in
    match pat.FStar_Parser_AST.pat with
    | FStar_Parser_AST.PatList pats ->
        handle_list (FStar_Parser_AST.Var FStar_Parser_Const.list_lid)
          (fun uu___ -> FStar_Parser_AST.PatList uu___) pats
    | FStar_Parser_AST.PatTuple (pats, dep) ->
        let uu___ =
          let uu___1 =
            (if dep
             then FStar_Parser_Const.mk_dtuple_lid
             else FStar_Parser_Const.mk_tuple_lid)
              (FStar_Compiler_List.length pats) pat.FStar_Parser_AST.prange in
          FStar_Parser_AST.Var uu___1 in
        handle_list uu___
          (fun pats1 -> FStar_Parser_AST.PatTuple (pats1, dep)) pats
    | FStar_Parser_AST.PatAscribed
        (pat1, (typ, FStar_Pervasives_Native.None)) ->
        (pat1, (FStar_Pervasives_Native.Some typ))
    | uu___ -> (pat, FStar_Pervasives_Native.None)
let (hoist_pat_ascription :
  FStar_Parser_AST.pattern -> FStar_Parser_AST.pattern) =
  fun pat ->
    let uu___ = hoist_pat_ascription' pat in
    match uu___ with
    | (pat1, typ) ->
        (match typ with
         | FStar_Pervasives_Native.Some typ1 ->
             {
               FStar_Parser_AST.pat =
                 (FStar_Parser_AST.PatAscribed
                    (pat1, (typ1, FStar_Pervasives_Native.None)));
               FStar_Parser_AST.prange = (pat1.FStar_Parser_AST.prange)
             }
         | FStar_Pervasives_Native.None -> pat1)
let rec (desugar_data_pat :
  Prims.bool ->
    env_t ->
      FStar_Parser_AST.pattern ->
        ((env_t * bnd * annotated_pat Prims.list) * antiquotations_temp))
  =
  fun top_level_ascr_allowed ->
    fun env ->
      fun p ->
        let resolvex l e x =
          let uu___ =
            FStar_Compiler_Util.find_opt
              (fun y ->
                 let uu___1 =
                   FStar_Ident.string_of_id y.FStar_Syntax_Syntax.ppname in
                 let uu___2 = FStar_Ident.string_of_id x in uu___1 = uu___2)
              l in
          match uu___ with
          | FStar_Pervasives_Native.Some y -> (l, e, y)
          | uu___1 ->
              let uu___2 = FStar_Syntax_DsEnv.push_bv e x in
              (match uu___2 with | (e1, xbv) -> ((xbv :: l), e1, xbv)) in
        let rec aux' top loc aqs env1 p1 =
          let pos q =
            FStar_Syntax_Syntax.withinfo q p1.FStar_Parser_AST.prange in
          let pos_r r q = FStar_Syntax_Syntax.withinfo q r in
          let orig = p1 in
          match p1.FStar_Parser_AST.pat with
          | FStar_Parser_AST.PatOr uu___ ->
              FStar_Compiler_Effect.failwith
                "impossible: PatOr handled below"
          | FStar_Parser_AST.PatOp op ->
              let id_op =
                let uu___ =
                  let uu___1 =
                    let uu___2 = FStar_Ident.string_of_id op in
                    let uu___3 = FStar_Ident.range_of_id op in
                    FStar_Parser_AST.compile_op Prims.int_zero uu___2 uu___3 in
                  let uu___2 = FStar_Ident.range_of_id op in (uu___1, uu___2) in
                FStar_Ident.mk_ident uu___ in
              let p2 =
                {
                  FStar_Parser_AST.pat =
                    (FStar_Parser_AST.PatVar
                       (id_op, FStar_Pervasives_Native.None, []));
                  FStar_Parser_AST.prange = (p1.FStar_Parser_AST.prange)
                } in
              aux loc aqs env1 p2
          | FStar_Parser_AST.PatAscribed (p2, (t, tacopt)) ->
              ((match tacopt with
                | FStar_Pervasives_Native.None -> ()
                | FStar_Pervasives_Native.Some uu___1 ->
                    FStar_Errors.raise_error
                      FStar_Parser_AST.hasRange_pattern orig
                      FStar_Errors_Codes.Fatal_TypeWithinPatternsAllowedOnVariablesOnly
                      () (Obj.magic FStar_Errors_Msg.is_error_message_string)
                      (Obj.magic
                         "Type ascriptions within patterns cannot be associated with a tactic"));
               (let uu___1 = aux loc aqs env1 p2 in
                match uu___1 with
                | (loc1, aqs1, env', binder, p3, annots) ->
                    let uu___2 =
                      match binder with
                      | LetBinder uu___3 ->
                          FStar_Compiler_Effect.failwith "impossible"
                      | LocalBinder (x, aq, attrs) ->
                          let uu___3 =
                            let uu___4 = close_fun env1 t in
                            desugar_term_aq env1 uu___4 in
                          (match uu___3 with
                           | (t1, aqs') ->
                               let x1 =
                                 {
                                   FStar_Syntax_Syntax.ppname =
                                     (x.FStar_Syntax_Syntax.ppname);
                                   FStar_Syntax_Syntax.index =
                                     (x.FStar_Syntax_Syntax.index);
                                   FStar_Syntax_Syntax.sort = t1
                                 } in
                               ([(x1, t1, attrs)],
                                 (LocalBinder (x1, aq, attrs)),
                                 (FStar_Compiler_List.op_At aqs' aqs1))) in
                    (match uu___2 with
                     | (annots', binder1, aqs2) ->
                         ((match p3.FStar_Syntax_Syntax.v with
                           | FStar_Syntax_Syntax.Pat_var uu___4 -> ()
                           | uu___4 when top && top_level_ascr_allowed -> ()
                           | uu___4 ->
                               FStar_Errors.raise_error
                                 FStar_Parser_AST.hasRange_pattern orig
                                 FStar_Errors_Codes.Fatal_TypeWithinPatternsAllowedOnVariablesOnly
                                 ()
                                 (Obj.magic
                                    FStar_Errors_Msg.is_error_message_string)
                                 (Obj.magic
                                    "Type ascriptions within patterns are only allowed on variables"));
                          (loc1, aqs2, env', binder1, p3,
                            (FStar_Compiler_List.op_At annots' annots))))))
          | FStar_Parser_AST.PatWild (aq, attrs) ->
              let aq1 = trans_bqual env1 aq in
              let attrs1 = FStar_Compiler_List.map (desugar_term env1) attrs in
              let x =
                let uu___ = tun_r p1.FStar_Parser_AST.prange in
                FStar_Syntax_Syntax.new_bv
                  (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                  uu___ in
              let uu___ = pos (FStar_Syntax_Syntax.Pat_var x) in
              (loc, aqs, env1, (LocalBinder (x, aq1, attrs1)), uu___, [])
          | FStar_Parser_AST.PatConst c ->
              let x =
                let uu___ = tun_r p1.FStar_Parser_AST.prange in
                FStar_Syntax_Syntax.new_bv
                  (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                  uu___ in
              let uu___ = pos (FStar_Syntax_Syntax.Pat_constant c) in
              (loc, aqs, env1,
                (LocalBinder (x, FStar_Pervasives_Native.None, [])), uu___,
                [])
          | FStar_Parser_AST.PatVQuote e ->
              let pat =
                let uu___ =
                  let uu___1 =
                    let uu___2 =
                      desugar_vquote env1 e p1.FStar_Parser_AST.prange in
                    (uu___2, (p1.FStar_Parser_AST.prange)) in
                  FStar_Const.Const_string uu___1 in
                FStar_Parser_AST.PatConst uu___ in
              aux' top loc aqs env1
                {
                  FStar_Parser_AST.pat = pat;
                  FStar_Parser_AST.prange = (p1.FStar_Parser_AST.prange)
                }
          | FStar_Parser_AST.PatTvar (x, aq, attrs) ->
              let aq1 = trans_bqual env1 aq in
              let attrs1 = FStar_Compiler_List.map (desugar_term env1) attrs in
              let uu___ = resolvex loc env1 x in
              (match uu___ with
               | (loc1, env2, xbv) ->
                   let uu___1 = pos (FStar_Syntax_Syntax.Pat_var xbv) in
                   (loc1, aqs, env2, (LocalBinder (xbv, aq1, attrs1)),
                     uu___1, []))
          | FStar_Parser_AST.PatVar (x, aq, attrs) ->
              let aq1 = trans_bqual env1 aq in
              let attrs1 = FStar_Compiler_List.map (desugar_term env1) attrs in
              let uu___ = resolvex loc env1 x in
              (match uu___ with
               | (loc1, env2, xbv) ->
                   let uu___1 = pos (FStar_Syntax_Syntax.Pat_var xbv) in
                   (loc1, aqs, env2, (LocalBinder (xbv, aq1, attrs1)),
                     uu___1, []))
          | FStar_Parser_AST.PatName l ->
              let l1 =
                FStar_Syntax_DsEnv.fail_or env1
                  (FStar_Syntax_DsEnv.try_lookup_datacon env1) l in
              let x =
                let uu___ = tun_r p1.FStar_Parser_AST.prange in
                FStar_Syntax_Syntax.new_bv
                  (FStar_Pervasives_Native.Some (p1.FStar_Parser_AST.prange))
                  uu___ in
              let uu___ =
                pos
                  (FStar_Syntax_Syntax.Pat_cons
                     (l1, FStar_Pervasives_Native.None, [])) in
              (loc, aqs, env1,
                (LocalBinder (x, FStar_Pervasives_Native.None, [])), uu___,
                [])
          | FStar_Parser_AST.PatApp
              ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatName l;
                 FStar_Parser_AST.prange = uu___;_},
               args)
              ->
              let uu___1 =
                FStar_Compiler_List.fold_right
                  (fun arg ->
                     fun uu___2 ->
                       match uu___2 with
                       | (loc1, aqs1, env2, annots, args1) ->
                           let uu___3 = aux loc1 aqs1 env2 arg in
                           (match uu___3 with
                            | (loc2, aqs2, env3, b, arg1, ans) ->
                                let imp = is_implicit b in
                                (loc2, aqs2, env3,
                                  (FStar_Compiler_List.op_At ans annots),
                                  ((arg1, imp) :: args1)))) args
                  (loc, aqs, env1, [], []) in
              (match uu___1 with
               | (loc1, aqs1, env2, annots, args1) ->
                   let l1 =
                     FStar_Syntax_DsEnv.fail_or env2
                       (FStar_Syntax_DsEnv.try_lookup_datacon env2) l in
                   let x =
                     let uu___2 = tun_r p1.FStar_Parser_AST.prange in
                     FStar_Syntax_Syntax.new_bv
                       (FStar_Pervasives_Native.Some
                          (p1.FStar_Parser_AST.prange)) uu___2 in
                   let uu___2 =
                     pos
                       (FStar_Syntax_Syntax.Pat_cons
                          (l1, FStar_Pervasives_Native.None, args1)) in
                   (loc1, aqs1, env2,
                     (LocalBinder (x, FStar_Pervasives_Native.None, [])),
                     uu___2, annots))
          | FStar_Parser_AST.PatApp uu___ ->
              FStar_Errors.raise_error FStar_Parser_AST.hasRange_pattern p1
                FStar_Errors_Codes.Fatal_UnexpectedPattern ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic "Unexpected pattern")
          | FStar_Parser_AST.PatList pats ->
              let uu___ =
                FStar_Compiler_List.fold_right
                  (fun pat ->
                     fun uu___1 ->
                       match uu___1 with
                       | (loc1, aqs1, env2, annots, pats1) ->
                           let uu___2 = aux loc1 aqs1 env2 pat in
                           (match uu___2 with
                            | (loc2, aqs2, env3, uu___3, pat1, ans) ->
                                (loc2, aqs2, env3,
                                  (FStar_Compiler_List.op_At ans annots),
                                  (pat1 :: pats1)))) pats
                  (loc, aqs, env1, [], []) in
              (match uu___ with
               | (loc1, aqs1, env2, annots, pats1) ->
                   let pat =
                     let uu___1 =
                       let uu___2 =
                         FStar_Compiler_Range_Ops.end_range
                           p1.FStar_Parser_AST.prange in
                       let uu___3 =
                         let uu___4 =
                           let uu___5 =
                             FStar_Syntax_Syntax.lid_and_dd_as_fv
                               FStar_Parser_Const.nil_lid
                               (FStar_Pervasives_Native.Some
                                  FStar_Syntax_Syntax.Data_ctor) in
                           (uu___5, FStar_Pervasives_Native.None, []) in
                         FStar_Syntax_Syntax.Pat_cons uu___4 in
                       pos_r uu___2 uu___3 in
                     FStar_Compiler_List.fold_right
                       (fun hd ->
                          fun tl ->
                            let r =
                              FStar_Compiler_Range_Ops.union_ranges
                                hd.FStar_Syntax_Syntax.p
                                tl.FStar_Syntax_Syntax.p in
                            let uu___2 =
                              let uu___3 =
                                let uu___4 =
                                  FStar_Syntax_Syntax.lid_and_dd_as_fv
                                    FStar_Parser_Const.cons_lid
                                    (FStar_Pervasives_Native.Some
                                       FStar_Syntax_Syntax.Data_ctor) in
                                (uu___4, FStar_Pervasives_Native.None,
                                  [(hd, false); (tl, false)]) in
                              FStar_Syntax_Syntax.Pat_cons uu___3 in
                            pos_r r uu___2) pats1 uu___1 in
                   let x =
                     let uu___1 = tun_r p1.FStar_Parser_AST.prange in
                     FStar_Syntax_Syntax.new_bv
                       (FStar_Pervasives_Native.Some
                          (p1.FStar_Parser_AST.prange)) uu___1 in
                   (loc1, aqs1, env2,
                     (LocalBinder (x, FStar_Pervasives_Native.None, [])),
                     pat, annots))
          | FStar_Parser_AST.PatTuple (args, dep) ->
              let uu___ =
                FStar_Compiler_List.fold_left
                  (fun uu___1 ->
                     fun p2 ->
                       match uu___1 with
                       | (loc1, aqs1, env2, annots, pats) ->
                           let uu___2 = aux loc1 aqs1 env2 p2 in
                           (match uu___2 with
                            | (loc2, aqs2, env3, uu___3, pat, ans) ->
                                (loc2, aqs2, env3,
                                  (FStar_Compiler_List.op_At ans annots),
                                  ((pat, false) :: pats))))
                  (loc, aqs, env1, [], []) args in
              (match uu___ with
               | (loc1, aqs1, env2, annots, args1) ->
                   let args2 = FStar_Compiler_List.rev args1 in
                   let l =
                     if dep
                     then
                       FStar_Parser_Const.mk_dtuple_data_lid
                         (FStar_Compiler_List.length args2)
                         p1.FStar_Parser_AST.prange
                     else
                       FStar_Parser_Const.mk_tuple_data_lid
                         (FStar_Compiler_List.length args2)
                         p1.FStar_Parser_AST.prange in
                   let constr =
                     FStar_Syntax_DsEnv.fail_or env2
                       (FStar_Syntax_DsEnv.try_lookup_lid env2) l in
                   let l1 =
                     match constr.FStar_Syntax_Syntax.n with
                     | FStar_Syntax_Syntax.Tm_fvar fv -> fv
                     | uu___1 -> FStar_Compiler_Effect.failwith "impossible" in
                   let x =
                     let uu___1 = tun_r p1.FStar_Parser_AST.prange in
                     FStar_Syntax_Syntax.new_bv
                       (FStar_Pervasives_Native.Some
                          (p1.FStar_Parser_AST.prange)) uu___1 in
                   let uu___1 =
                     pos
                       (FStar_Syntax_Syntax.Pat_cons
                          (l1, FStar_Pervasives_Native.None, args2)) in
                   (loc1, aqs1, env2,
                     (LocalBinder (x, FStar_Pervasives_Native.None, [])),
                     uu___1, annots))
          | FStar_Parser_AST.PatRecord fields ->
              let uu___ = FStar_Compiler_List.unzip fields in
              (match uu___ with
               | (field_names, pats) ->
                   let uu___1 =
                     match fields with
                     | [] -> (FStar_Pervasives_Native.None, field_names)
                     | (f, uu___2)::uu___3 ->
                         let uu___4 =
                           FStar_Syntax_DsEnv.try_lookup_record_by_field_name
                             env1 f in
                         (match uu___4 with
                          | FStar_Pervasives_Native.None ->
                              (FStar_Pervasives_Native.None, field_names)
                          | FStar_Pervasives_Native.Some r ->
                              let uu___5 =
                                qualify_field_names
                                  r.FStar_Syntax_DsEnv.typename field_names in
                              ((FStar_Pervasives_Native.Some
                                  (r.FStar_Syntax_DsEnv.typename)), uu___5)) in
                   (match uu___1 with
                    | (typename, field_names1) ->
                        let candidate_constructor =
                          let lid =
                            FStar_Ident.lid_of_path ["__dummy__"]
                              p1.FStar_Parser_AST.prange in
                          FStar_Syntax_Syntax.lid_and_dd_as_fv lid
                            (FStar_Pervasives_Native.Some
                               (FStar_Syntax_Syntax.Unresolved_constructor
                                  {
                                    FStar_Syntax_Syntax.uc_base_term = false;
                                    FStar_Syntax_Syntax.uc_typename =
                                      typename;
                                    FStar_Syntax_Syntax.uc_fields =
                                      field_names1
                                  })) in
                        let uu___2 =
                          FStar_Compiler_List.fold_left
                            (fun uu___3 ->
                               fun p2 ->
                                 match uu___3 with
                                 | (loc1, aqs1, env2, annots, pats1) ->
                                     let uu___4 = aux loc1 aqs1 env2 p2 in
                                     (match uu___4 with
                                      | (loc2, aqs2, env3, uu___5, pat, ann)
                                          ->
                                          (loc2, aqs2, env3,
                                            (FStar_Compiler_List.op_At ann
                                               annots), ((pat, false) ::
                                            pats1))))
                            (loc, aqs, env1, [], []) pats in
                        (match uu___2 with
                         | (loc1, aqs1, env2, annots, pats1) ->
                             let pats2 = FStar_Compiler_List.rev pats1 in
                             let pat =
                               pos
                                 (FStar_Syntax_Syntax.Pat_cons
                                    (candidate_constructor,
                                      FStar_Pervasives_Native.None, pats2)) in
                             let x =
                               let uu___3 = tun_r p1.FStar_Parser_AST.prange in
                               FStar_Syntax_Syntax.new_bv
                                 (FStar_Pervasives_Native.Some
                                    (p1.FStar_Parser_AST.prange)) uu___3 in
                             (loc1, aqs1, env2,
                               (LocalBinder
                                  (x, FStar_Pervasives_Native.None, [])),
                               pat, annots))))
        and aux loc aqs env1 p1 = aux' false loc aqs env1 p1 in
        let aux_maybe_or env1 p1 =
          let loc = [] in
          match p1.FStar_Parser_AST.pat with
          | FStar_Parser_AST.PatOr [] ->
              FStar_Compiler_Effect.failwith "impossible"
          | FStar_Parser_AST.PatOr (p2::ps) ->
              let uu___ = aux' true loc [] env1 p2 in
              (match uu___ with
               | (loc1, aqs, env2, var, p3, ans) ->
                   let uu___1 =
                     FStar_Compiler_List.fold_left
                       (fun uu___2 ->
                          fun p4 ->
                            match uu___2 with
                            | (loc2, aqs1, env3, ps1) ->
                                let uu___3 = aux' true loc2 aqs1 env3 p4 in
                                (match uu___3 with
                                 | (loc3, aqs2, env4, uu___4, p5, ans1) ->
                                     (loc3, aqs2, env4, ((p5, ans1) :: ps1))))
                       (loc1, aqs, env2, []) ps in
                   (match uu___1 with
                    | (loc2, aqs1, env3, ps1) ->
                        let pats = (p3, ans) :: (FStar_Compiler_List.rev ps1) in
                        ((env3, var, pats), aqs1)))
          | uu___ ->
              let uu___1 = aux' true loc [] env1 p1 in
              (match uu___1 with
               | (loc1, aqs, env2, var, pat, ans) ->
                   ((env2, var, [(pat, ans)]), aqs)) in
        let uu___ = aux_maybe_or env p in
        match uu___ with
        | ((env1, b, pats), aqs) ->
            ((let uu___2 =
                FStar_Compiler_List.map FStar_Pervasives_Native.fst pats in
              check_linear_pattern_variables uu___2 p.FStar_Parser_AST.prange);
             ((env1, b, pats), aqs))
and (desugar_binding_pat_maybe_top :
  Prims.bool ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.pattern ->
        ((env_t * bnd * annotated_pat Prims.list) * antiquotations_temp))
  =
  fun top ->
    fun env ->
      fun p ->
        if top
        then
          let mklet x ty tacopt =
            let uu___ =
              let uu___1 =
                let uu___2 = FStar_Syntax_DsEnv.qualify env x in
                (uu___2, (ty, tacopt)) in
              LetBinder uu___1 in
            (env, uu___, []) in
          let op_to_ident x =
            let uu___ =
              let uu___1 =
                let uu___2 = FStar_Ident.string_of_id x in
                let uu___3 = FStar_Ident.range_of_id x in
                FStar_Parser_AST.compile_op Prims.int_zero uu___2 uu___3 in
              let uu___2 = FStar_Ident.range_of_id x in (uu___1, uu___2) in
            FStar_Ident.mk_ident uu___ in
          match p.FStar_Parser_AST.pat with
          | FStar_Parser_AST.PatOp x ->
              let uu___ =
                let uu___1 = op_to_ident x in
                let uu___2 =
                  let uu___3 = FStar_Ident.range_of_id x in tun_r uu___3 in
                mklet uu___1 uu___2 FStar_Pervasives_Native.None in
              (uu___, [])
          | FStar_Parser_AST.PatVar (x, uu___, uu___1) ->
              let uu___2 =
                let uu___3 =
                  let uu___4 = FStar_Ident.range_of_id x in tun_r uu___4 in
                mklet x uu___3 FStar_Pervasives_Native.None in
              (uu___2, [])
          | FStar_Parser_AST.PatAscribed
              ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatOp x;
                 FStar_Parser_AST.prange = uu___;_},
               (t, tacopt))
              ->
              let tacopt1 =
                FStar_Compiler_Util.map_opt tacopt (desugar_term env) in
              let uu___1 = desugar_term_aq env t in
              (match uu___1 with
               | (t1, aq) ->
                   let uu___2 =
                     let uu___3 = op_to_ident x in mklet uu___3 t1 tacopt1 in
                   (uu___2, aq))
          | FStar_Parser_AST.PatAscribed
              ({
                 FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                   (x, uu___, uu___1);
                 FStar_Parser_AST.prange = uu___2;_},
               (t, tacopt))
              ->
              let tacopt1 =
                FStar_Compiler_Util.map_opt tacopt (desugar_term env) in
              let uu___3 = desugar_term_aq env t in
              (match uu___3 with
               | (t1, aq) -> let uu___4 = mklet x t1 tacopt1 in (uu___4, aq))
          | uu___ ->
              FStar_Errors.raise_error FStar_Parser_AST.hasRange_pattern p
                FStar_Errors_Codes.Fatal_UnexpectedPattern ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic "Unexpected pattern at the top-level")
        else
          (let uu___1 = desugar_data_pat true env p in
           match uu___1 with
           | ((env1, binder, p1), aq) ->
               let p2 =
                 match p1 with
                 | ({
                      FStar_Syntax_Syntax.v = FStar_Syntax_Syntax.Pat_var
                        uu___2;
                      FStar_Syntax_Syntax.p = uu___3;_},
                    uu___4)::[] -> []
                 | uu___2 -> p1 in
               ((env1, binder, p2), aq))
and (desugar_binding_pat_aq :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.pattern ->
      ((env_t * bnd * annotated_pat Prims.list) * antiquotations_temp))
  = fun env -> fun p -> desugar_binding_pat_maybe_top false env p
and (desugar_match_pat_maybe_top :
  Prims.bool ->
    env_t ->
      FStar_Parser_AST.pattern ->
        ((env_t * annotated_pat Prims.list) * antiquotations_temp))
  =
  fun uu___ ->
    fun env ->
      fun pat ->
        let uu___1 = desugar_data_pat false env pat in
        match uu___1 with
        | ((env1, uu___2, pat1), aqs) -> ((env1, pat1), aqs)
and (desugar_match_pat :
  env_t ->
    FStar_Parser_AST.pattern ->
      ((env_t * annotated_pat Prims.list) * antiquotations_temp))
  = fun env -> fun p -> desugar_match_pat_maybe_top false env p
and (desugar_term_aq :
  env_t ->
    FStar_Parser_AST.term -> (FStar_Syntax_Syntax.term * antiquotations_temp))
  =
  fun env ->
    fun e ->
      let env1 = FStar_Syntax_DsEnv.set_expect_typ env false in
      desugar_term_maybe_top false env1 e
and (desugar_term :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env ->
    fun e ->
      let uu___ = desugar_term_aq env e in
      match uu___ with | (t, aq) -> (check_no_aq aq; t)
and (desugar_typ_aq :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.term -> (FStar_Syntax_Syntax.term * antiquotations_temp))
  =
  fun env ->
    fun e ->
      let env1 = FStar_Syntax_DsEnv.set_expect_typ env true in
      desugar_term_maybe_top false env1 e
and (desugar_typ :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env ->
    fun e ->
      let uu___ = desugar_typ_aq env e in
      match uu___ with | (t, aq) -> (check_no_aq aq; t)
and (desugar_machine_integer :
  FStar_Syntax_DsEnv.env ->
    Prims.string ->
      (FStar_Const.signedness * FStar_Const.width) ->
        FStar_Compiler_Range_Type.range -> FStar_Syntax_Syntax.term)
  =
  fun env ->
    fun repr ->
      fun uu___ ->
        fun range ->
          match uu___ with
          | (signedness, width) ->
              let tnm =
                if width = FStar_Const.Sizet
                then "FStar.SizeT"
                else
                  Prims.strcat "FStar."
                    (Prims.strcat
                       (match signedness with
                        | FStar_Const.Unsigned -> "U"
                        | FStar_Const.Signed -> "")
                       (Prims.strcat "Int"
                          (match width with
                           | FStar_Const.Int8 -> "8"
                           | FStar_Const.Int16 -> "16"
                           | FStar_Const.Int32 -> "32"
                           | FStar_Const.Int64 -> "64"))) in
              ((let uu___2 =
                  let uu___3 =
                    FStar_Const.within_bounds repr signedness width in
                  Prims.op_Negation uu___3 in
                if uu___2
                then
                  let uu___3 =
                    FStar_Compiler_Util.format2
                      "%s is not in the expected range for %s" repr tnm in
                  FStar_Errors.log_issue FStar_Class_HasRange.hasRange_range
                    range FStar_Errors_Codes.Error_OutOfRange ()
                    (Obj.magic FStar_Errors_Msg.is_error_message_string)
                    (Obj.magic uu___3)
                else ());
               (let private_intro_nm =
                  Prims.strcat tnm
                    (Prims.strcat ".__"
                       (Prims.strcat
                          (match signedness with
                           | FStar_Const.Unsigned -> "u"
                           | FStar_Const.Signed -> "") "int_to_t")) in
                let intro_nm =
                  Prims.strcat tnm
                    (Prims.strcat "."
                       (Prims.strcat
                          (match signedness with
                           | FStar_Const.Unsigned -> "u"
                           | FStar_Const.Signed -> "") "int_to_t")) in
                let lid =
                  let uu___2 = FStar_Ident.path_of_text intro_nm in
                  FStar_Ident.lid_of_path uu___2 range in
                let lid1 =
                  let uu___2 = FStar_Syntax_DsEnv.try_lookup_lid env lid in
                  match uu___2 with
                  | FStar_Pervasives_Native.Some intro_term ->
                      (match intro_term.FStar_Syntax_Syntax.n with
                       | FStar_Syntax_Syntax.Tm_fvar fv ->
                           let private_lid =
                             let uu___3 =
                               FStar_Ident.path_of_text private_intro_nm in
                             FStar_Ident.lid_of_path uu___3 range in
                           let private_fv =
                             FStar_Syntax_Syntax.lid_and_dd_as_fv private_lid
                               fv.FStar_Syntax_Syntax.fv_qual in
                           {
                             FStar_Syntax_Syntax.n =
                               (FStar_Syntax_Syntax.Tm_fvar private_fv);
                             FStar_Syntax_Syntax.pos =
                               (intro_term.FStar_Syntax_Syntax.pos);
                             FStar_Syntax_Syntax.vars =
                               (intro_term.FStar_Syntax_Syntax.vars);
                             FStar_Syntax_Syntax.hash_code =
                               (intro_term.FStar_Syntax_Syntax.hash_code)
                           }
                       | uu___3 ->
                           FStar_Compiler_Effect.failwith
                             (Prims.strcat "Unexpected non-fvar for "
                                intro_nm))
                  | FStar_Pervasives_Native.None ->
                      let uu___3 =
                        FStar_Compiler_Util.format1
                          "Unexpected numeric literal.  Restart F* to load %s."
                          tnm in
                      FStar_Errors.raise_error
                        FStar_Class_HasRange.hasRange_range range
                        FStar_Errors_Codes.Fatal_UnexpectedNumericLiteral ()
                        (Obj.magic FStar_Errors_Msg.is_error_message_string)
                        (Obj.magic uu___3) in
                let repr' =
                  FStar_Syntax_Syntax.mk
                    (FStar_Syntax_Syntax.Tm_constant
                       (FStar_Const.Const_int
                          (repr, FStar_Pervasives_Native.None))) range in
                let app =
                  let uu___2 =
                    let uu___3 =
                      let uu___4 =
                        let uu___5 =
                          let uu___6 =
                            FStar_Syntax_Syntax.as_aqual_implicit false in
                          (repr', uu___6) in
                        [uu___5] in
                      {
                        FStar_Syntax_Syntax.hd = lid1;
                        FStar_Syntax_Syntax.args = uu___4
                      } in
                    FStar_Syntax_Syntax.Tm_app uu___3 in
                  FStar_Syntax_Syntax.mk uu___2 range in
                FStar_Syntax_Syntax.mk
                  (FStar_Syntax_Syntax.Tm_meta
                     {
                       FStar_Syntax_Syntax.tm2 = app;
                       FStar_Syntax_Syntax.meta =
                         (FStar_Syntax_Syntax.Meta_desugared
                            (FStar_Syntax_Syntax.Machine_integer
                               (signedness, width)))
                     }) range))
and (desugar_term_maybe_top :
  Prims.bool ->
    env_t ->
      FStar_Parser_AST.term ->
        (FStar_Syntax_Syntax.term * antiquotations_temp))
  =
  fun top_level ->
    fun env ->
      fun top ->
        let mk e = FStar_Syntax_Syntax.mk e top.FStar_Parser_AST.range in
        let noaqs = [] in
        let join_aqs aqs = FStar_Compiler_List.flatten aqs in
        let setpos e =
          {
            FStar_Syntax_Syntax.n = (e.FStar_Syntax_Syntax.n);
            FStar_Syntax_Syntax.pos = (top.FStar_Parser_AST.range);
            FStar_Syntax_Syntax.vars = (e.FStar_Syntax_Syntax.vars);
            FStar_Syntax_Syntax.hash_code = (e.FStar_Syntax_Syntax.hash_code)
          } in
        let desugar_binders env1 binders =
          let uu___ =
            FStar_Compiler_List.fold_left
              (fun uu___1 ->
                 fun b ->
                   match uu___1 with
                   | (env2, bs) ->
                       let bb = desugar_binder env2 b in
                       let uu___2 =
                         as_binder env2 b.FStar_Parser_AST.aqual bb in
                       (match uu___2 with | (b1, env3) -> (env3, (b1 :: bs))))
              (env1, []) binders in
          match uu___ with
          | (env2, bs_rev) -> (env2, (FStar_Compiler_List.rev bs_rev)) in
        let unqual_bv_of_binder b =
          match b with
          | { FStar_Syntax_Syntax.binder_bv = x;
              FStar_Syntax_Syntax.binder_qual = FStar_Pervasives_Native.None;
              FStar_Syntax_Syntax.binder_positivity = uu___;
              FStar_Syntax_Syntax.binder_attrs = [];_} -> x
          | uu___ ->
              FStar_Errors.raise_error FStar_Syntax_Syntax.hasRange_binder b
                FStar_Errors_Codes.Fatal_UnexpectedTerm ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic "Unexpected qualified binder in ELIM_EXISTS") in
        (let uu___1 = FStar_Compiler_Effect.op_Bang dbg_ToSyntax in
         if uu___1
         then
           let uu___2 =
             FStar_Class_Show.show FStar_Parser_AST.showable_term top in
           FStar_Compiler_Util.print1 "desugaring (%s)\n\n" uu___2
         else ());
        (let uu___1 = let uu___2 = unparen top in uu___2.FStar_Parser_AST.tm in
         match uu___1 with
         | FStar_Parser_AST.Wild -> ((setpos FStar_Syntax_Syntax.tun), noaqs)
         | FStar_Parser_AST.Labeled uu___2 ->
             let uu___3 = desugar_formula env top in (uu___3, noaqs)
         | FStar_Parser_AST.Requires (t, lopt) ->
             let uu___2 = desugar_formula env t in (uu___2, noaqs)
         | FStar_Parser_AST.Ensures (t, lopt) ->
             let uu___2 = desugar_formula env t in (uu___2, noaqs)
         | FStar_Parser_AST.Attributes ts ->
             FStar_Compiler_Effect.failwith
               "Attributes should not be desugared by desugar_term_maybe_top"
         | FStar_Parser_AST.Const (FStar_Const.Const_int
             (i, FStar_Pervasives_Native.Some size)) ->
             let uu___2 =
               desugar_machine_integer env i size top.FStar_Parser_AST.range in
             (uu___2, noaqs)
         | FStar_Parser_AST.Const c ->
             let uu___2 = mk (FStar_Syntax_Syntax.Tm_constant c) in
             (uu___2, noaqs)
         | FStar_Parser_AST.Op (id, args) when
             let uu___2 = FStar_Ident.string_of_id id in uu___2 = "=!=" ->
             let r = FStar_Ident.range_of_id id in
             let e =
               let uu___2 =
                 let uu___3 =
                   let uu___4 = FStar_Ident.mk_ident ("==", r) in
                   (uu___4, args) in
                 FStar_Parser_AST.Op uu___3 in
               FStar_Parser_AST.mk_term uu___2 top.FStar_Parser_AST.range
                 top.FStar_Parser_AST.level in
             let uu___2 =
               let uu___3 =
                 let uu___4 =
                   let uu___5 = FStar_Ident.mk_ident ("~", r) in
                   (uu___5, [e]) in
                 FStar_Parser_AST.Op uu___4 in
               FStar_Parser_AST.mk_term uu___3 top.FStar_Parser_AST.range
                 top.FStar_Parser_AST.level in
             desugar_term_aq env uu___2
         | FStar_Parser_AST.Op (op_star, lhs::rhs::[]) when
             (let uu___2 = FStar_Ident.string_of_id op_star in uu___2 = "*")
               &&
               (let uu___2 = op_as_term env (Prims.of_int (2)) op_star in
                FStar_Compiler_Option.isNone uu___2)
             ->
             let rec flatten t =
               match t.FStar_Parser_AST.tm with
               | FStar_Parser_AST.Op (id, t1::t2::[]) when
                   (let uu___2 = FStar_Ident.string_of_id id in uu___2 = "*")
                     &&
                     (let uu___2 = op_as_term env (Prims.of_int (2)) op_star in
                      FStar_Compiler_Option.isNone uu___2)
                   ->
                   let uu___2 = flatten t1 in
                   FStar_Compiler_List.op_At uu___2 [t2]
               | uu___2 -> [t] in
             let terms = flatten lhs in
             let t =
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     FStar_Compiler_List.map
                       (fun uu___5 -> FStar_Pervasives.Inr uu___5) terms in
                   (uu___4, rhs) in
                 FStar_Parser_AST.Sum uu___3 in
               {
                 FStar_Parser_AST.tm = uu___2;
                 FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                 FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
               } in
             desugar_term_maybe_top top_level env t
         | FStar_Parser_AST.Tvar a ->
             let uu___2 =
               let uu___3 =
                 FStar_Syntax_DsEnv.fail_or2
                   (FStar_Syntax_DsEnv.try_lookup_id env) a in
               setpos uu___3 in
             (uu___2, noaqs)
         | FStar_Parser_AST.Uvar u ->
             let uu___2 =
               let uu___3 =
                 let uu___4 = FStar_Ident.string_of_id u in
                 Prims.strcat uu___4 " in non-universe context" in
               Prims.strcat "Unexpected universe variable " uu___3 in
             FStar_Errors.raise_error FStar_Parser_AST.hasRange_term top
               FStar_Errors_Codes.Fatal_UnexpectedUniverseVariable ()
               (Obj.magic FStar_Errors_Msg.is_error_message_string)
               (Obj.magic uu___2)
         | FStar_Parser_AST.Op (s, f::e::[]) when
             let uu___2 = FStar_Ident.string_of_id s in uu___2 = "<|" ->
             let uu___2 =
               FStar_Parser_AST.mkApp f [(e, FStar_Parser_AST.Nothing)]
                 top.FStar_Parser_AST.range in
             desugar_term_maybe_top top_level env uu___2
         | FStar_Parser_AST.Op (s, e::f::[]) when
             let uu___2 = FStar_Ident.string_of_id s in uu___2 = "|>" ->
             let uu___2 =
               FStar_Parser_AST.mkApp f [(e, FStar_Parser_AST.Nothing)]
                 top.FStar_Parser_AST.range in
             desugar_term_maybe_top top_level env uu___2
         | FStar_Parser_AST.Op (s, args) ->
             let uu___2 = op_as_term env (FStar_Compiler_List.length args) s in
             (match uu___2 with
              | FStar_Pervasives_Native.None ->
                  let uu___3 =
                    let uu___4 = FStar_Ident.string_of_id s in
                    Prims.strcat "Unexpected or unbound operator: " uu___4 in
                  FStar_Errors.raise_error FStar_Ident.hasrange_ident s
                    FStar_Errors_Codes.Fatal_UnepxectedOrUnboundOperator ()
                    (Obj.magic FStar_Errors_Msg.is_error_message_string)
                    (Obj.magic uu___3)
              | FStar_Pervasives_Native.Some op ->
                  if (FStar_Compiler_List.length args) > Prims.int_zero
                  then
                    let uu___3 =
                      let uu___4 =
                        FStar_Compiler_List.map
                          (fun t ->
                             let uu___5 = desugar_term_aq env t in
                             match uu___5 with
                             | (t', s1) ->
                                 ((t', FStar_Pervasives_Native.None), s1))
                          args in
                      FStar_Compiler_List.unzip uu___4 in
                    (match uu___3 with
                     | (args1, aqs) ->
                         let uu___4 =
                           mk
                             (FStar_Syntax_Syntax.Tm_app
                                {
                                  FStar_Syntax_Syntax.hd = op;
                                  FStar_Syntax_Syntax.args = args1
                                }) in
                         (uu___4, (join_aqs aqs)))
                  else (op, noaqs))
         | FStar_Parser_AST.Construct (n, (a, uu___2)::[]) when
             let uu___3 = FStar_Ident.string_of_lid n in uu___3 = "SMTPat" ->
             let uu___3 =
               let uu___4 =
                 let uu___5 =
                   let uu___6 =
                     let uu___7 =
                       let uu___8 = smt_pat_lid top.FStar_Parser_AST.range in
                       FStar_Parser_AST.Var uu___8 in
                     {
                       FStar_Parser_AST.tm = uu___7;
                       FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                       FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
                     } in
                   (uu___6, a, FStar_Parser_AST.Nothing) in
                 FStar_Parser_AST.App uu___5 in
               {
                 FStar_Parser_AST.tm = uu___4;
                 FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                 FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
               } in
             desugar_term_maybe_top top_level env uu___3
         | FStar_Parser_AST.Construct (n, (a, uu___2)::[]) when
             let uu___3 = FStar_Ident.string_of_lid n in uu___3 = "SMTPatT"
             ->
             (FStar_Errors.log_issue FStar_Parser_AST.hasRange_term top
                FStar_Errors_Codes.Warning_SMTPatTDeprecated ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic "SMTPatT is deprecated; please just use SMTPat");
              (let uu___4 =
                 let uu___5 =
                   let uu___6 =
                     let uu___7 =
                       let uu___8 =
                         let uu___9 = smt_pat_lid top.FStar_Parser_AST.range in
                         FStar_Parser_AST.Var uu___9 in
                       {
                         FStar_Parser_AST.tm = uu___8;
                         FStar_Parser_AST.range =
                           (top.FStar_Parser_AST.range);
                         FStar_Parser_AST.level =
                           (top.FStar_Parser_AST.level)
                       } in
                     (uu___7, a, FStar_Parser_AST.Nothing) in
                   FStar_Parser_AST.App uu___6 in
                 {
                   FStar_Parser_AST.tm = uu___5;
                   FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                   FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
                 } in
               desugar_term_maybe_top top_level env uu___4))
         | FStar_Parser_AST.Construct (n, (a, uu___2)::[]) when
             let uu___3 = FStar_Ident.string_of_lid n in uu___3 = "SMTPatOr"
             ->
             let uu___3 =
               let uu___4 =
                 let uu___5 =
                   let uu___6 =
                     let uu___7 =
                       let uu___8 = smt_pat_or_lid top.FStar_Parser_AST.range in
                       FStar_Parser_AST.Var uu___8 in
                     {
                       FStar_Parser_AST.tm = uu___7;
                       FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                       FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
                     } in
                   (uu___6, a, FStar_Parser_AST.Nothing) in
                 FStar_Parser_AST.App uu___5 in
               {
                 FStar_Parser_AST.tm = uu___4;
                 FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                 FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
               } in
             desugar_term_maybe_top top_level env uu___3
         | FStar_Parser_AST.Name lid when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "Type0"
             ->
             let uu___2 =
               mk (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_zero) in
             (uu___2, noaqs)
         | FStar_Parser_AST.Name lid when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "Type" ->
             let uu___2 =
               mk (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown) in
             (uu___2, noaqs)
         | FStar_Parser_AST.Construct
             (lid, (t, FStar_Parser_AST.UnivApp)::[]) when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "Type" ->
             let uu___2 =
               let uu___3 =
                 let uu___4 = desugar_universe t in
                 FStar_Syntax_Syntax.Tm_type uu___4 in
               mk uu___3 in
             (uu___2, noaqs)
         | FStar_Parser_AST.Name lid when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "Effect"
             ->
             let uu___2 =
               mk (FStar_Syntax_Syntax.Tm_constant FStar_Const.Const_effect) in
             (uu___2, noaqs)
         | FStar_Parser_AST.Name lid when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "True" ->
             let uu___2 =
               let uu___3 =
                 FStar_Ident.set_lid_range FStar_Parser_Const.true_lid
                   top.FStar_Parser_AST.range in
               FStar_Syntax_Syntax.fvar_with_dd uu___3
                 FStar_Pervasives_Native.None in
             (uu___2, noaqs)
         | FStar_Parser_AST.Name lid when
             let uu___2 = FStar_Ident.string_of_lid lid in uu___2 = "False"
             ->
             let uu___2 =
               let uu___3 =
                 FStar_Ident.set_lid_range FStar_Parser_Const.false_lid
                   top.FStar_Parser_AST.range in
               FStar_Syntax_Syntax.fvar_with_dd uu___3
                 FStar_Pervasives_Native.None in
             (uu___2, noaqs)
         | FStar_Parser_AST.Projector (eff_name, id) when
             (let uu___2 = FStar_Ident.string_of_id id in
              is_special_effect_combinator uu___2) &&
               (FStar_Syntax_DsEnv.is_effect_name env eff_name)
             ->
             let txt = FStar_Ident.string_of_id id in
             let uu___2 =
               FStar_Syntax_DsEnv.try_lookup_effect_defn env eff_name in
             (match uu___2 with
              | FStar_Pervasives_Native.Some ed ->
                  let lid = FStar_Syntax_Util.dm4f_lid ed txt in
                  let uu___3 =
                    FStar_Syntax_Syntax.fvar_with_dd lid
                      FStar_Pervasives_Native.None in
                  (uu___3, noaqs)
              | FStar_Pervasives_Native.None ->
                  let uu___3 =
                    let uu___4 = FStar_Ident.string_of_lid eff_name in
                    FStar_Compiler_Util.format2
                      "Member %s of effect %s is not accessible (using an effect abbreviation instead of the original effect ?)"
                      uu___4 txt in
                  FStar_Compiler_Effect.failwith uu___3)
         | FStar_Parser_AST.Var l ->
             let uu___2 = desugar_name mk setpos env true l in
             (uu___2, noaqs)
         | FStar_Parser_AST.Name l ->
             let uu___2 = desugar_name mk setpos env true l in
             (uu___2, noaqs)
         | FStar_Parser_AST.Projector (l, i) ->
             let name =
               let uu___2 = FStar_Syntax_DsEnv.try_lookup_datacon env l in
               match uu___2 with
               | FStar_Pervasives_Native.Some uu___3 ->
                   FStar_Pervasives_Native.Some (true, l)
               | FStar_Pervasives_Native.None ->
                   let uu___3 =
                     FStar_Syntax_DsEnv.try_lookup_root_effect_name env l in
                   (match uu___3 with
                    | FStar_Pervasives_Native.Some new_name ->
                        FStar_Pervasives_Native.Some (false, new_name)
                    | uu___4 -> FStar_Pervasives_Native.None) in
             (match name with
              | FStar_Pervasives_Native.Some (resolve, new_name) ->
                  let uu___2 =
                    let uu___3 =
                      FStar_Syntax_Util.mk_field_projector_name_from_ident
                        new_name i in
                    desugar_name mk setpos env resolve uu___3 in
                  (uu___2, noaqs)
              | uu___2 ->
                  let uu___3 =
                    let uu___4 = FStar_Ident.string_of_lid l in
                    FStar_Compiler_Util.format1
                      "Data constructor or effect %s not found" uu___4 in
                  FStar_Errors.raise_error FStar_Parser_AST.hasRange_term top
                    FStar_Errors_Codes.Fatal_EffectNotFound ()
                    (Obj.magic FStar_Errors_Msg.is_error_message_string)
                    (Obj.magic uu___3))
         | FStar_Parser_AST.Discrim lid ->
             let uu___2 = FStar_Syntax_DsEnv.try_lookup_datacon env lid in
             (match uu___2 with
              | FStar_Pervasives_Native.None ->
                  let uu___3 =
                    let uu___4 = FStar_Ident.string_of_lid lid in
                    FStar_Compiler_Util.format1
                      "Data constructor %s not found" uu___4 in
                  FStar_Errors.raise_error FStar_Parser_AST.hasRange_term top
                    FStar_Errors_Codes.Fatal_DataContructorNotFound ()
                    (Obj.magic FStar_Errors_Msg.is_error_message_string)
                    (Obj.magic uu___3)
              | uu___3 ->
                  let lid' = FStar_Syntax_Util.mk_discriminator lid in
                  let uu___4 = desugar_name mk setpos env true lid' in
                  (uu___4, noaqs))
         | FStar_Parser_AST.Construct (l, args) ->
             let uu___2 = FStar_Syntax_DsEnv.try_lookup_datacon env l in
             (match uu___2 with
              | FStar_Pervasives_Native.Some head ->
                  let head1 = mk (FStar_Syntax_Syntax.Tm_fvar head) in
                  (match args with
                   | [] -> (head1, noaqs)
                   | uu___3 ->
                       let uu___4 =
                         FStar_Compiler_Util.take
                           (fun uu___5 ->
                              match uu___5 with
                              | (uu___6, imp) ->
                                  imp = FStar_Parser_AST.UnivApp) args in
                       (match uu___4 with
                        | (universes, args1) ->
                            let universes1 =
                              FStar_Compiler_List.map
                                (fun x ->
                                   desugar_universe
                                     (FStar_Pervasives_Native.fst x))
                                universes in
                            let uu___5 =
                              let uu___6 =
                                FStar_Compiler_List.map
                                  (fun uu___7 ->
                                     match uu___7 with
                                     | (t, imp) ->
                                         let uu___8 = desugar_term_aq env t in
                                         (match uu___8 with
                                          | (te, aq) ->
                                              let uu___9 =
                                                arg_withimp_t imp te in
                                              (uu___9, aq))) args1 in
                              FStar_Compiler_List.unzip uu___6 in
                            (match uu___5 with
                             | (args2, aqs) ->
                                 let head2 =
                                   if universes1 = []
                                   then head1
                                   else
                                     mk
                                       (FStar_Syntax_Syntax.Tm_uinst
                                          (head1, universes1)) in
                                 let tm =
                                   if
                                     (FStar_Compiler_List.length args2) =
                                       Prims.int_zero
                                   then head2
                                   else
                                     mk
                                       (FStar_Syntax_Syntax.Tm_app
                                          {
                                            FStar_Syntax_Syntax.hd = head2;
                                            FStar_Syntax_Syntax.args = args2
                                          }) in
                                 (tm, (join_aqs aqs)))))
              | FStar_Pervasives_Native.None ->
                  let uu___3 =
                    FStar_Syntax_DsEnv.try_lookup_effect_name env l in
                  (match uu___3 with
                   | FStar_Pervasives_Native.None ->
                       let uu___4 =
                         let uu___5 =
                           let uu___6 = FStar_Ident.string_of_lid l in
                           Prims.strcat uu___6 " not found" in
                         Prims.strcat "Constructor " uu___5 in
                       FStar_Errors.raise_error FStar_Ident.hasrange_lident l
                         FStar_Errors_Codes.Fatal_ConstructorNotFound ()
                         (Obj.magic FStar_Errors_Msg.is_error_message_string)
                         (Obj.magic uu___4)
                   | FStar_Pervasives_Native.Some uu___4 ->
                       let uu___5 =
                         let uu___6 =
                           let uu___7 = FStar_Ident.string_of_lid l in
                           Prims.strcat uu___7
                             " used at an unexpected position" in
                         Prims.strcat "Effect " uu___6 in
                       FStar_Errors.raise_error FStar_Ident.hasrange_lident l
                         FStar_Errors_Codes.Fatal_UnexpectedEffect ()
                         (Obj.magic FStar_Errors_Msg.is_error_message_string)
                         (Obj.magic uu___5)))
         | FStar_Parser_AST.Sum (binders, t) when
             FStar_Compiler_Util.for_all
               (fun uu___2 ->
                  match uu___2 with
                  | FStar_Pervasives.Inr uu___3 -> true
                  | uu___3 -> false) binders
             ->
             let terms =
               let uu___2 =
                 FStar_Compiler_List.map
                   (fun uu___3 ->
                      match uu___3 with
                      | FStar_Pervasives.Inr x -> x
                      | FStar_Pervasives.Inl uu___4 ->
                          FStar_Compiler_Effect.failwith "Impossible")
                   binders in
               FStar_Compiler_List.op_At uu___2 [t] in
             let uu___2 =
               let uu___3 =
                 FStar_Compiler_List.map
                   (fun t1 ->
                      let uu___4 = desugar_typ_aq env t1 in
                      match uu___4 with
                      | (t', aq) ->
                          let uu___5 = FStar_Syntax_Syntax.as_arg t' in
                          (uu___5, aq)) terms in
               FStar_Compiler_List.unzip uu___3 in
             (match uu___2 with
              | (targs, aqs) ->
                  let tup =
                    let uu___3 =
                      FStar_Parser_Const.mk_tuple_lid
                        (FStar_Compiler_List.length targs)
                        top.FStar_Parser_AST.range in
                    FStar_Syntax_DsEnv.fail_or env
                      (FStar_Syntax_DsEnv.try_lookup_lid env) uu___3 in
                  let uu___3 =
                    mk
                      (FStar_Syntax_Syntax.Tm_app
                         {
                           FStar_Syntax_Syntax.hd = tup;
                           FStar_Syntax_Syntax.args = targs
                         }) in
                  (uu___3, (join_aqs aqs)))
         | FStar_Parser_AST.Sum (binders, t) ->
             let uu___2 =
               let uu___3 =
                 let uu___4 =
                   let uu___5 =
                     let uu___6 =
                       FStar_Parser_AST.mk_binder (FStar_Parser_AST.NoName t)
                         t.FStar_Parser_AST.range FStar_Parser_AST.Type_level
                         FStar_Pervasives_Native.None in
                     FStar_Pervasives.Inl uu___6 in
                   [uu___5] in
                 FStar_Compiler_List.op_At binders uu___4 in
               FStar_Compiler_List.fold_left
                 (fun uu___4 ->
                    fun b ->
                      match uu___4 with
                      | (env1, tparams, typs) ->
                          let uu___5 =
                            match b with
                            | FStar_Pervasives.Inl b1 ->
                                desugar_binder env1 b1
                            | FStar_Pervasives.Inr t1 ->
                                let uu___6 = desugar_typ env1 t1 in
                                (FStar_Pervasives_Native.None, uu___6, []) in
                          (match uu___5 with
                           | (xopt, t1, attrs) ->
                               let uu___6 =
                                 match xopt with
                                 | FStar_Pervasives_Native.None ->
                                     let uu___7 =
                                       FStar_Syntax_Syntax.new_bv
                                         (FStar_Pervasives_Native.Some
                                            (top.FStar_Parser_AST.range))
                                         (setpos FStar_Syntax_Syntax.tun) in
                                     (env1, uu___7)
                                 | FStar_Pervasives_Native.Some x ->
                                     FStar_Syntax_DsEnv.push_bv env1 x in
                               (match uu___6 with
                                | (env2, x) ->
                                    let uu___7 =
                                      let uu___8 =
                                        let uu___9 =
                                          mk_binder_with_attrs
                                            {
                                              FStar_Syntax_Syntax.ppname =
                                                (x.FStar_Syntax_Syntax.ppname);
                                              FStar_Syntax_Syntax.index =
                                                (x.FStar_Syntax_Syntax.index);
                                              FStar_Syntax_Syntax.sort = t1
                                            } FStar_Pervasives_Native.None
                                            attrs in
                                        [uu___9] in
                                      FStar_Compiler_List.op_At tparams
                                        uu___8 in
                                    let uu___8 =
                                      let uu___9 =
                                        let uu___10 =
                                          let uu___11 =
                                            no_annot_abs tparams t1 in
                                          FStar_Syntax_Syntax.as_arg uu___11 in
                                        [uu___10] in
                                      FStar_Compiler_List.op_At typs uu___9 in
                                    (env2, uu___7, uu___8)))) (env, [], [])
                 uu___3 in
             (match uu___2 with
              | (env1, uu___3, targs) ->
                  let tup =
                    let uu___4 =
                      FStar_Parser_Const.mk_dtuple_lid
                        (FStar_Compiler_List.length targs)
                        top.FStar_Parser_AST.range in
                    FStar_Syntax_DsEnv.fail_or env1
                      (FStar_Syntax_DsEnv.try_lookup_lid env1) uu___4 in
                  let uu___4 =
                    mk
                      (FStar_Syntax_Syntax.Tm_app
                         {
                           FStar_Syntax_Syntax.hd = tup;
                           FStar_Syntax_Syntax.args = targs
                         }) in
                  (uu___4, noaqs))
         | FStar_Parser_AST.Product (binders, t) ->
             let uu___2 = uncurry binders t in
             (match uu___2 with
              | (bs, t1) ->
                  let rec aux env1 aqs bs1 uu___3 =
                    match uu___3 with
                    | [] ->
                        let cod =
                          desugar_comp top.FStar_Parser_AST.range true env1
                            t1 in
                        let uu___4 =
                          let uu___5 =
                            FStar_Syntax_Util.arrow
                              (FStar_Compiler_List.rev bs1) cod in
                          setpos uu___5 in
                        (uu___4, aqs)
                    | hd::tl ->
                        let uu___4 = desugar_binder_aq env1 hd in
                        (match uu___4 with
                         | (bb, aqs') ->
                             let uu___5 =
                               as_binder env1 hd.FStar_Parser_AST.aqual bb in
                             (match uu___5 with
                              | (b, env2) ->
                                  aux env2
                                    (FStar_Compiler_List.op_At aqs' aqs) (b
                                    :: bs1) tl)) in
                  aux env [] [] bs)
         | FStar_Parser_AST.Refine (b, f) ->
             let uu___2 = desugar_binder env b in
             (match uu___2 with
              | (FStar_Pervasives_Native.None, uu___3, uu___4) ->
                  FStar_Compiler_Effect.failwith
                    "Missing binder in refinement"
              | b1 ->
                  let uu___3 = as_binder env FStar_Pervasives_Native.None b1 in
                  (match uu___3 with
                   | (b2, env1) ->
                       let f1 = desugar_formula env1 f in
                       let uu___4 =
                         let uu___5 =
                           FStar_Syntax_Util.refine
                             b2.FStar_Syntax_Syntax.binder_bv f1 in
                         setpos uu___5 in
                       (uu___4, noaqs)))
         | FStar_Parser_AST.Function (branches, r1) ->
             let x = FStar_Ident.gen r1 in
             let t' =
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     let uu___5 =
                       FStar_Parser_AST.mk_pattern
                         (FStar_Parser_AST.PatVar
                            (x, FStar_Pervasives_Native.None, [])) r1 in
                     [uu___5] in
                   let uu___5 =
                     let uu___6 =
                       let uu___7 =
                         let uu___8 =
                           let uu___9 =
                             let uu___10 = FStar_Ident.lid_of_ids [x] in
                             FStar_Parser_AST.Var uu___10 in
                           FStar_Parser_AST.mk_term uu___9 r1
                             FStar_Parser_AST.Expr in
                         (uu___8, FStar_Pervasives_Native.None,
                           FStar_Pervasives_Native.None, branches) in
                       FStar_Parser_AST.Match uu___7 in
                     FStar_Parser_AST.mk_term uu___6
                       top.FStar_Parser_AST.range FStar_Parser_AST.Expr in
                   (uu___4, uu___5) in
                 FStar_Parser_AST.Abs uu___3 in
               FStar_Parser_AST.mk_term uu___2 top.FStar_Parser_AST.range
                 FStar_Parser_AST.Expr in
             desugar_term_maybe_top top_level env t'
         | FStar_Parser_AST.Abs (binders, body) ->
             let bvss =
               FStar_Compiler_List.map gather_pattern_bound_vars binders in
             let check_disjoint sets =
               let rec aux acc sets1 =
                 match sets1 with
                 | [] -> FStar_Pervasives_Native.None
                 | set::sets2 ->
                     let i =
                       Obj.magic
                         (FStar_Class_Setlike.inter ()
                            (Obj.magic
                               (FStar_Compiler_FlatSet.setlike_flat_set
                                  FStar_Syntax_Syntax.ord_ident))
                            (Obj.magic acc) (Obj.magic set)) in
                     let uu___2 =
                       FStar_Class_Setlike.is_empty ()
                         (Obj.magic
                            (FStar_Compiler_FlatSet.setlike_flat_set
                               FStar_Syntax_Syntax.ord_ident)) (Obj.magic i) in
                     if uu___2
                     then
                       let uu___3 =
                         Obj.magic
                           (FStar_Class_Setlike.union ()
                              (Obj.magic
                                 (FStar_Compiler_FlatSet.setlike_flat_set
                                    FStar_Syntax_Syntax.ord_ident))
                              (Obj.magic acc) (Obj.magic set)) in
                       aux uu___3 sets2
                     else
                       (let uu___4 =
                          let uu___5 =
                            FStar_Class_Setlike.elems ()
                              (Obj.magic
                                 (FStar_Compiler_FlatSet.setlike_flat_set
                                    FStar_Syntax_Syntax.ord_ident))
                              (Obj.magic i) in
                          FStar_Compiler_List.hd uu___5 in
                        FStar_Pervasives_Native.Some uu___4) in
               let uu___2 =
                 Obj.magic
                   (FStar_Class_Setlike.empty ()
                      (Obj.magic
                         (FStar_Compiler_FlatSet.setlike_flat_set
                            FStar_Syntax_Syntax.ord_ident)) ()) in
               aux uu___2 sets in
             ((let uu___3 = check_disjoint bvss in
               match uu___3 with
               | FStar_Pervasives_Native.None -> ()
               | FStar_Pervasives_Native.Some id ->
                   let uu___4 =
                     let uu___5 =
                       FStar_Errors_Msg.text
                         "Non-linear patterns are not permitted." in
                     let uu___6 =
                       let uu___7 =
                         let uu___8 = FStar_Errors_Msg.text "The variable " in
                         let uu___9 =
                           let uu___10 =
                             let uu___11 =
                               FStar_Class_PP.pp FStar_Ident.pretty_ident id in
                             FStar_Pprint.squotes uu___11 in
                           let uu___11 =
                             FStar_Errors_Msg.text
                               " appears more than once in this function definition." in
                           FStar_Pprint.op_Hat_Slash_Hat uu___10 uu___11 in
                         FStar_Pprint.op_Hat_Slash_Hat uu___8 uu___9 in
                       [uu___7] in
                     uu___5 :: uu___6 in
                   FStar_Errors.raise_error FStar_Ident.hasrange_ident id
                     FStar_Errors_Codes.Fatal_NonLinearPatternNotPermitted ()
                     (Obj.magic FStar_Errors_Msg.is_error_message_list_doc)
                     (Obj.magic uu___4));
              (let binders1 =
                 FStar_Compiler_List.map replace_unit_pattern binders in
               let uu___3 =
                 FStar_Compiler_List.fold_left
                   (fun uu___4 ->
                      fun pat ->
                        match uu___4 with
                        | (env1, ftvs) ->
                            (match pat.FStar_Parser_AST.pat with
                             | FStar_Parser_AST.PatAscribed
                                 (uu___5, (t, FStar_Pervasives_Native.None))
                                 ->
                                 let uu___6 =
                                   let uu___7 = free_type_vars env1 t in
                                   FStar_Compiler_List.op_At uu___7 ftvs in
                                 (env1, uu___6)
                             | FStar_Parser_AST.PatAscribed
                                 (uu___5,
                                  (t, FStar_Pervasives_Native.Some tac))
                                 ->
                                 let uu___6 =
                                   let uu___7 = free_type_vars env1 t in
                                   let uu___8 =
                                     let uu___9 = free_type_vars env1 tac in
                                     FStar_Compiler_List.op_At uu___9 ftvs in
                                   FStar_Compiler_List.op_At uu___7 uu___8 in
                                 (env1, uu___6)
                             | uu___5 -> (env1, ftvs))) (env, []) binders1 in
               match uu___3 with
               | (uu___4, ftv) ->
                   let ftv1 = sort_ftv ftv in
                   let binders2 =
                     let uu___5 =
                       FStar_Compiler_List.map
                         (fun a ->
                            FStar_Parser_AST.mk_pattern
                              (FStar_Parser_AST.PatTvar
                                 (a,
                                   (FStar_Pervasives_Native.Some
                                      FStar_Parser_AST.Implicit), []))
                              top.FStar_Parser_AST.range) ftv1 in
                     FStar_Compiler_List.op_At uu___5 binders1 in
                   let rec aux aqs env1 bs sc_pat_opt pats =
                     match pats with
                     | [] ->
                         let uu___5 = desugar_term_aq env1 body in
                         (match uu___5 with
                          | (body1, aq) ->
                              let body2 =
                                match sc_pat_opt with
                                | FStar_Pervasives_Native.Some (sc, pat) ->
                                    let body3 =
                                      let uu___6 =
                                        let uu___7 =
                                          FStar_Syntax_Syntax.pat_bvs pat in
                                        FStar_Compiler_List.map
                                          FStar_Syntax_Syntax.mk_binder
                                          uu___7 in
                                      FStar_Syntax_Subst.close uu___6 body1 in
                                    FStar_Syntax_Syntax.mk
                                      (FStar_Syntax_Syntax.Tm_match
                                         {
                                           FStar_Syntax_Syntax.scrutinee = sc;
                                           FStar_Syntax_Syntax.ret_opt =
                                             FStar_Pervasives_Native.None;
                                           FStar_Syntax_Syntax.brs =
                                             [(pat,
                                                FStar_Pervasives_Native.None,
                                                body3)];
                                           FStar_Syntax_Syntax.rc_opt1 =
                                             FStar_Pervasives_Native.None
                                         }) body3.FStar_Syntax_Syntax.pos
                                | FStar_Pervasives_Native.None -> body1 in
                              let uu___6 =
                                let uu___7 =
                                  no_annot_abs (FStar_Compiler_List.rev bs)
                                    body2 in
                                setpos uu___7 in
                              (uu___6, (FStar_Compiler_List.op_At aq aqs)))
                     | p::rest ->
                         let uu___5 = desugar_binding_pat_aq env1 p in
                         (match uu___5 with
                          | ((env2, b, pat), aq) ->
                              let pat1 =
                                match pat with
                                | [] -> FStar_Pervasives_Native.None
                                | (p1, uu___6)::[] ->
                                    FStar_Pervasives_Native.Some p1
                                | uu___6 ->
                                    FStar_Errors.raise_error
                                      FStar_Parser_AST.hasRange_pattern p
                                      FStar_Errors_Codes.Fatal_UnsupportedDisjuctivePatterns
                                      ()
                                      (Obj.magic
                                         FStar_Errors_Msg.is_error_message_string)
                                      (Obj.magic
                                         "Disjunctive patterns are not supported in abstractions") in
                              let uu___6 =
                                match b with
                                | LetBinder uu___7 ->
                                    FStar_Compiler_Effect.failwith
                                      "Impossible"
                                | LocalBinder (x, aq1, attrs) ->
                                    let sc_pat_opt1 =
                                      match (pat1, sc_pat_opt) with
                                      | (FStar_Pervasives_Native.None,
                                         uu___7) -> sc_pat_opt
                                      | (FStar_Pervasives_Native.Some p1,
                                         FStar_Pervasives_Native.None) ->
                                          let uu___7 =
                                            let uu___8 =
                                              FStar_Syntax_Syntax.bv_to_name
                                                x in
                                            (uu___8, p1) in
                                          FStar_Pervasives_Native.Some uu___7
                                      | (FStar_Pervasives_Native.Some p1,
                                         FStar_Pervasives_Native.Some
                                         (sc, p')) ->
                                          (match ((sc.FStar_Syntax_Syntax.n),
                                                   (p'.FStar_Syntax_Syntax.v))
                                           with
                                           | (FStar_Syntax_Syntax.Tm_name
                                              uu___7, uu___8) ->
                                               let tup2 =
                                                 let uu___9 =
                                                   FStar_Parser_Const.mk_tuple_data_lid
                                                     (Prims.of_int (2))
                                                     top.FStar_Parser_AST.range in
                                                 FStar_Syntax_Syntax.lid_and_dd_as_fv
                                                   uu___9
                                                   (FStar_Pervasives_Native.Some
                                                      FStar_Syntax_Syntax.Data_ctor) in
                                               let sc1 =
                                                 let uu___9 =
                                                   let uu___10 =
                                                     let uu___11 =
                                                       mk
                                                         (FStar_Syntax_Syntax.Tm_fvar
                                                            tup2) in
                                                     let uu___12 =
                                                       let uu___13 =
                                                         FStar_Syntax_Syntax.as_arg
                                                           sc in
                                                       let uu___14 =
                                                         let uu___15 =
                                                           let uu___16 =
                                                             FStar_Syntax_Syntax.bv_to_name
                                                               x in
                                                           FStar_Syntax_Syntax.as_arg
                                                             uu___16 in
                                                         [uu___15] in
                                                       uu___13 :: uu___14 in
                                                     {
                                                       FStar_Syntax_Syntax.hd
                                                         = uu___11;
                                                       FStar_Syntax_Syntax.args
                                                         = uu___12
                                                     } in
                                                   FStar_Syntax_Syntax.Tm_app
                                                     uu___10 in
                                                 FStar_Syntax_Syntax.mk
                                                   uu___9
                                                   top.FStar_Parser_AST.range in
                                               let p2 =
                                                 let uu___9 =
                                                   FStar_Compiler_Range_Ops.union_ranges
                                                     p'.FStar_Syntax_Syntax.p
                                                     p1.FStar_Syntax_Syntax.p in
                                                 FStar_Syntax_Syntax.withinfo
                                                   (FStar_Syntax_Syntax.Pat_cons
                                                      (tup2,
                                                        FStar_Pervasives_Native.None,
                                                        [(p', false);
                                                        (p1, false)])) uu___9 in
                                               FStar_Pervasives_Native.Some
                                                 (sc1, p2)
                                           | (FStar_Syntax_Syntax.Tm_app
                                              {
                                                FStar_Syntax_Syntax.hd =
                                                  uu___7;
                                                FStar_Syntax_Syntax.args =
                                                  args;_},
                                              FStar_Syntax_Syntax.Pat_cons
                                              (uu___8, uu___9, pats1)) ->
                                               let tupn =
                                                 let uu___10 =
                                                   FStar_Parser_Const.mk_tuple_data_lid
                                                     (Prims.int_one +
                                                        (FStar_Compiler_List.length
                                                           args))
                                                     top.FStar_Parser_AST.range in
                                                 FStar_Syntax_Syntax.lid_and_dd_as_fv
                                                   uu___10
                                                   (FStar_Pervasives_Native.Some
                                                      FStar_Syntax_Syntax.Data_ctor) in
                                               let sc1 =
                                                 let uu___10 =
                                                   let uu___11 =
                                                     let uu___12 =
                                                       mk
                                                         (FStar_Syntax_Syntax.Tm_fvar
                                                            tupn) in
                                                     let uu___13 =
                                                       let uu___14 =
                                                         let uu___15 =
                                                           let uu___16 =
                                                             FStar_Syntax_Syntax.bv_to_name
                                                               x in
                                                           FStar_Syntax_Syntax.as_arg
                                                             uu___16 in
                                                         [uu___15] in
                                                       FStar_Compiler_List.op_At
                                                         args uu___14 in
                                                     {
                                                       FStar_Syntax_Syntax.hd
                                                         = uu___12;
                                                       FStar_Syntax_Syntax.args
                                                         = uu___13
                                                     } in
                                                   FStar_Syntax_Syntax.Tm_app
                                                     uu___11 in
                                                 mk uu___10 in
                                               let p2 =
                                                 let uu___10 =
                                                   FStar_Compiler_Range_Ops.union_ranges
                                                     p'.FStar_Syntax_Syntax.p
                                                     p1.FStar_Syntax_Syntax.p in
                                                 FStar_Syntax_Syntax.withinfo
                                                   (FStar_Syntax_Syntax.Pat_cons
                                                      (tupn,
                                                        FStar_Pervasives_Native.None,
                                                        (FStar_Compiler_List.op_At
                                                           pats1
                                                           [(p1, false)])))
                                                   uu___10 in
                                               FStar_Pervasives_Native.Some
                                                 (sc1, p2)
                                           | uu___7 ->
                                               FStar_Compiler_Effect.failwith
                                                 "Impossible") in
                                    let uu___7 =
                                      mk_binder_with_attrs x aq1 attrs in
                                    (uu___7, sc_pat_opt1) in
                              (match uu___6 with
                               | (b1, sc_pat_opt1) ->
                                   aux (FStar_Compiler_List.op_At aq aqs)
                                     env2 (b1 :: bs) sc_pat_opt1 rest)) in
                   aux [] env [] FStar_Pervasives_Native.None binders2))
         | FStar_Parser_AST.App (uu___2, uu___3, FStar_Parser_AST.UnivApp) ->
             let rec aux universes e =
               let uu___4 =
                 let uu___5 = unparen e in uu___5.FStar_Parser_AST.tm in
               match uu___4 with
               | FStar_Parser_AST.App (e1, t, FStar_Parser_AST.UnivApp) ->
                   let univ_arg = desugar_universe t in
                   aux (univ_arg :: universes) e1
               | uu___5 ->
                   let uu___6 = desugar_term_aq env e in
                   (match uu___6 with
                    | (head, aq) ->
                        let uu___7 =
                          mk (FStar_Syntax_Syntax.Tm_uinst (head, universes)) in
                        (uu___7, aq)) in
             aux [] top
         | FStar_Parser_AST.App (e, t, imp) ->
             let uu___2 = desugar_term_aq env e in
             (match uu___2 with
              | (head, aq1) ->
                  let uu___3 = desugar_term_aq env t in
                  (match uu___3 with
                   | (t1, aq2) ->
                       let arg = arg_withimp_t imp t1 in
                       let uu___4 =
                         FStar_Syntax_Syntax.extend_app head arg
                           top.FStar_Parser_AST.range in
                       (uu___4, (FStar_Compiler_List.op_At aq1 aq2))))
         | FStar_Parser_AST.Bind (x, t1, t2) ->
             let xpat =
               let uu___2 = FStar_Ident.range_of_id x in
               FStar_Parser_AST.mk_pattern
                 (FStar_Parser_AST.PatVar
                    (x, FStar_Pervasives_Native.None, [])) uu___2 in
             let k =
               FStar_Parser_AST.mk_term (FStar_Parser_AST.Abs ([xpat], t2))
                 t2.FStar_Parser_AST.range t2.FStar_Parser_AST.level in
             let bind_lid =
               let uu___2 = FStar_Ident.range_of_id x in
               FStar_Ident.lid_of_path ["bind"] uu___2 in
             let bind =
               let uu___2 = FStar_Ident.range_of_id x in
               FStar_Parser_AST.mk_term (FStar_Parser_AST.Var bind_lid)
                 uu___2 FStar_Parser_AST.Expr in
             let uu___2 =
               FStar_Parser_AST.mkExplicitApp bind [t1; k]
                 top.FStar_Parser_AST.range in
             desugar_term_aq env uu___2
         | FStar_Parser_AST.Seq (t1, t2) ->
             let p =
               FStar_Parser_AST.mk_pattern
                 (FStar_Parser_AST.PatWild (FStar_Pervasives_Native.None, []))
                 t1.FStar_Parser_AST.range in
             let p1 =
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     let uu___5 = unit_ty p.FStar_Parser_AST.prange in
                     (uu___5, FStar_Pervasives_Native.None) in
                   (p, uu___4) in
                 FStar_Parser_AST.PatAscribed uu___3 in
               FStar_Parser_AST.mk_pattern uu___2 p.FStar_Parser_AST.prange in
             let t =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Let
                    (FStar_Parser_AST.NoLetQualifier,
                      [(FStar_Pervasives_Native.None, (p1, t1))], t2))
                 top.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             let uu___2 = desugar_term_aq env t in
             (match uu___2 with
              | (tm, s) ->
                  let uu___3 =
                    mk
                      (FStar_Syntax_Syntax.Tm_meta
                         {
                           FStar_Syntax_Syntax.tm2 = tm;
                           FStar_Syntax_Syntax.meta =
                             (FStar_Syntax_Syntax.Meta_desugared
                                FStar_Syntax_Syntax.Sequence)
                         }) in
                  (uu___3, s))
         | FStar_Parser_AST.LetOpen (lid, e) ->
             let env1 =
               FStar_Syntax_DsEnv.push_namespace env lid
                 FStar_Syntax_Syntax.Unrestricted in
             let uu___2 =
               let uu___3 = FStar_Syntax_DsEnv.expect_typ env1 in
               if uu___3 then desugar_typ_aq else desugar_term_aq in
             uu___2 env1 e
         | FStar_Parser_AST.LetOpenRecord (r, rty, e) ->
             let rec head_of t =
               match t.FStar_Parser_AST.tm with
               | FStar_Parser_AST.App (t1, uu___2, uu___3) -> head_of t1
               | uu___2 -> t in
             let tycon = head_of rty in
             let tycon_name =
               match tycon.FStar_Parser_AST.tm with
               | FStar_Parser_AST.Var l -> l
               | uu___2 ->
                   let uu___3 =
                     let uu___4 = FStar_Parser_AST.term_to_string rty in
                     FStar_Compiler_Util.format1
                       "This type must be a (possibly applied) record name"
                       uu___4 in
                   FStar_Errors.raise_error FStar_Parser_AST.hasRange_term
                     rty FStar_Errors_Codes.Error_BadLetOpenRecord ()
                     (Obj.magic FStar_Errors_Msg.is_error_message_string)
                     (Obj.magic uu___3) in
             let record =
               let uu___2 =
                 FStar_Syntax_DsEnv.try_lookup_record_type env tycon_name in
               match uu___2 with
               | FStar_Pervasives_Native.Some r1 -> r1
               | FStar_Pervasives_Native.None ->
                   let uu___3 =
                     let uu___4 = FStar_Parser_AST.term_to_string rty in
                     FStar_Compiler_Util.format1 "Not a record type: `%s`"
                       uu___4 in
                   FStar_Errors.raise_error FStar_Parser_AST.hasRange_term
                     rty FStar_Errors_Codes.Error_BadLetOpenRecord ()
                     (Obj.magic FStar_Errors_Msg.is_error_message_string)
                     (Obj.magic uu___3) in
             let constrname =
               let uu___2 =
                 FStar_Ident.ns_of_lid record.FStar_Syntax_DsEnv.typename in
               FStar_Ident.lid_of_ns_and_id uu___2
                 record.FStar_Syntax_DsEnv.constrname in
             let mk_pattern p =
               FStar_Parser_AST.mk_pattern p r.FStar_Parser_AST.range in
             let elab =
               let pat =
                 let uu___2 =
                   let uu___3 =
                     let uu___4 =
                       mk_pattern (FStar_Parser_AST.PatName constrname) in
                     let uu___5 =
                       FStar_Compiler_List.map
                         (fun uu___6 ->
                            match uu___6 with
                            | (field, uu___7) ->
                                mk_pattern
                                  (FStar_Parser_AST.PatVar
                                     (field, FStar_Pervasives_Native.None,
                                       []))) record.FStar_Syntax_DsEnv.fields in
                     (uu___4, uu___5) in
                   FStar_Parser_AST.PatApp uu___3 in
                 mk_pattern uu___2 in
               let branch = (pat, FStar_Pervasives_Native.None, e) in
               let r1 =
                 FStar_Parser_AST.mk_term
                   (FStar_Parser_AST.Ascribed
                      (r, rty, FStar_Pervasives_Native.None, false))
                   r.FStar_Parser_AST.range FStar_Parser_AST.Expr in
               {
                 FStar_Parser_AST.tm =
                   (FStar_Parser_AST.Match
                      (r1, FStar_Pervasives_Native.None,
                        FStar_Pervasives_Native.None, [branch]));
                 FStar_Parser_AST.range = (top.FStar_Parser_AST.range);
                 FStar_Parser_AST.level = (top.FStar_Parser_AST.level)
               } in
             desugar_term_maybe_top top_level env elab
         | FStar_Parser_AST.LetOperator (lets, body) ->
             (match lets with
              | [] ->
                  FStar_Compiler_Effect.failwith
                    "Impossible: a LetOperator (e.g. let+, let*...) cannot contain zero let binding"
              | (letOp, letPat, letDef)::tl ->
                  let term_of_op op =
                    let uu___2 = FStar_Ident.range_of_id op in
                    FStar_Parser_AST.mk_term (FStar_Parser_AST.Op (op, []))
                      uu___2 FStar_Parser_AST.Expr in
                  let mproduct_def =
                    FStar_Compiler_List.fold_left
                      (fun def ->
                         fun uu___2 ->
                           match uu___2 with
                           | (andOp, andPat, andDef) ->
                               let uu___3 = term_of_op andOp in
                               FStar_Parser_AST.mkExplicitApp uu___3
                                 [def; andDef] top.FStar_Parser_AST.range)
                      letDef tl in
                  let mproduct_pat =
                    FStar_Compiler_List.fold_left
                      (fun pat ->
                         fun uu___2 ->
                           match uu___2 with
                           | (andOp, andPat, andDef) ->
                               FStar_Parser_AST.mk_pattern
                                 (FStar_Parser_AST.PatTuple
                                    ([pat; andPat], false))
                                 andPat.FStar_Parser_AST.prange) letPat tl in
                  let fn =
                    let uu___2 =
                      let uu___3 =
                        let uu___4 =
                          let uu___5 = hoist_pat_ascription mproduct_pat in
                          [uu___5] in
                        (uu___4, body) in
                      FStar_Parser_AST.Abs uu___3 in
                    FStar_Parser_AST.mk_term uu___2
                      body.FStar_Parser_AST.range body.FStar_Parser_AST.level in
                  let let_op = term_of_op letOp in
                  let t =
                    FStar_Parser_AST.mkExplicitApp let_op [mproduct_def; fn]
                      top.FStar_Parser_AST.range in
                  desugar_term_aq env t)
         | FStar_Parser_AST.Let (qual, lbs, body) ->
             let is_rec = qual = FStar_Parser_AST.Rec in
             let ds_let_rec_or_app uu___2 =
               let bindings = lbs in
               let funs =
                 FStar_Compiler_List.map
                   (fun uu___3 ->
                      match uu___3 with
                      | (attr_opt, (p, def)) ->
                          let uu___4 = is_app_pattern p in
                          if uu___4
                          then
                            let uu___5 = destruct_app_pattern env top_level p in
                            (attr_opt, uu___5, def)
                          else
                            (let uu___6 = FStar_Parser_AST.un_function p def in
                             match uu___6 with
                             | FStar_Pervasives_Native.Some (p1, def1) ->
                                 let uu___7 =
                                   destruct_app_pattern env top_level p1 in
                                 (attr_opt, uu___7, def1)
                             | uu___7 ->
                                 (match p.FStar_Parser_AST.pat with
                                  | FStar_Parser_AST.PatAscribed
                                      ({
                                         FStar_Parser_AST.pat =
                                           FStar_Parser_AST.PatVar
                                           (id, uu___8, uu___9);
                                         FStar_Parser_AST.prange = uu___10;_},
                                       t)
                                      ->
                                      if top_level
                                      then
                                        let uu___11 =
                                          let uu___12 =
                                            let uu___13 =
                                              FStar_Syntax_DsEnv.qualify env
                                                id in
                                            FStar_Pervasives.Inr uu___13 in
                                          (uu___12, [],
                                            (FStar_Pervasives_Native.Some t)) in
                                        (attr_opt, uu___11, def)
                                      else
                                        (attr_opt,
                                          ((FStar_Pervasives.Inl id), [],
                                            (FStar_Pervasives_Native.Some t)),
                                          def)
                                  | FStar_Parser_AST.PatVar
                                      (id, uu___8, uu___9) ->
                                      if top_level
                                      then
                                        let uu___10 =
                                          let uu___11 =
                                            let uu___12 =
                                              FStar_Syntax_DsEnv.qualify env
                                                id in
                                            FStar_Pervasives.Inr uu___12 in
                                          (uu___11, [],
                                            FStar_Pervasives_Native.None) in
                                        (attr_opt, uu___10, def)
                                      else
                                        (attr_opt,
                                          ((FStar_Pervasives.Inl id), [],
                                            FStar_Pervasives_Native.None),
                                          def)
                                  | uu___8 ->
                                      FStar_Errors.raise_error
                                        FStar_Parser_AST.hasRange_pattern p
                                        FStar_Errors_Codes.Fatal_UnexpectedLetBinding
                                        ()
                                        (Obj.magic
                                           FStar_Errors_Msg.is_error_message_string)
                                        (Obj.magic "Unexpected let binding"))))
                   bindings in
               let uu___3 =
                 FStar_Compiler_List.fold_left
                   (fun uu___4 ->
                      fun uu___5 ->
                        match (uu___4, uu___5) with
                        | ((env1, fnames, rec_bindings, used_markers),
                           (_attr_opt, (f, uu___6, uu___7), uu___8)) ->
                            let uu___9 =
                              match f with
                              | FStar_Pervasives.Inl x ->
                                  let uu___10 =
                                    FStar_Syntax_DsEnv.push_bv' env1 x in
                                  (match uu___10 with
                                   | (env2, xx, used_marker) ->
                                       let dummy_ref =
                                         FStar_Compiler_Util.mk_ref true in
                                       let uu___11 =
                                         let uu___12 =
                                           FStar_Syntax_Syntax.mk_binder xx in
                                         uu___12 :: rec_bindings in
                                       (env2, (FStar_Pervasives.Inl xx),
                                         uu___11, (used_marker ::
                                         used_markers)))
                              | FStar_Pervasives.Inr l ->
                                  let uu___10 =
                                    let uu___11 = FStar_Ident.ident_of_lid l in
                                    FStar_Syntax_DsEnv.push_top_level_rec_binding
                                      env1 uu___11 in
                                  (match uu___10 with
                                   | (env2, used_marker) ->
                                       (env2, (FStar_Pervasives.Inr l),
                                         rec_bindings, (used_marker ::
                                         used_markers))) in
                            (match uu___9 with
                             | (env2, lbname, rec_bindings1, used_markers1)
                                 ->
                                 (env2, (lbname :: fnames), rec_bindings1,
                                   used_markers1))) (env, [], [], []) funs in
               match uu___3 with
               | (env', fnames, rec_bindings, used_markers) ->
                   let fnames1 = FStar_Compiler_List.rev fnames in
                   let rec_bindings1 = FStar_Compiler_List.rev rec_bindings in
                   let used_markers1 = FStar_Compiler_List.rev used_markers in
                   let desugar_one_def env1 lbname uu___4 =
                     match uu___4 with
                     | (attrs_opt, (uu___5, args, result_t), def) ->
                         let args1 =
                           FStar_Compiler_List.map replace_unit_pattern args in
                         let pos = def.FStar_Parser_AST.range in
                         let def1 =
                           match result_t with
                           | FStar_Pervasives_Native.None -> def
                           | FStar_Pervasives_Native.Some (t, tacopt) ->
                               let t1 =
                                 let uu___6 = is_comp_type env1 t in
                                 if uu___6
                                 then
                                   ((let uu___8 =
                                       FStar_Compiler_List.tryFind
                                         (fun x ->
                                            let uu___9 = is_var_pattern x in
                                            Prims.op_Negation uu___9) args1 in
                                     match uu___8 with
                                     | FStar_Pervasives_Native.None -> ()
                                     | FStar_Pervasives_Native.Some p ->
                                         FStar_Errors.raise_error
                                           FStar_Parser_AST.hasRange_pattern
                                           p
                                           FStar_Errors_Codes.Fatal_ComputationTypeNotAllowed
                                           ()
                                           (Obj.magic
                                              FStar_Errors_Msg.is_error_message_string)
                                           (Obj.magic
                                              "Computation type annotations are only permitted on let-bindings without inlined patterns; replace this pattern with a variable"));
                                    t)
                                 else
                                   (let uu___8 =
                                      ((FStar_Options.ml_ish ()) &&
                                         (let uu___9 =
                                            let uu___10 =
                                              FStar_Parser_Const.effect_ML_lid
                                                () in
                                            FStar_Syntax_DsEnv.try_lookup_effect_name
                                              env1 uu___10 in
                                          FStar_Compiler_Option.isSome uu___9))
                                        &&
                                        ((Prims.op_Negation is_rec) ||
                                           ((FStar_Compiler_List.length args1)
                                              <> Prims.int_zero)) in
                                    if uu___8
                                    then FStar_Parser_AST.ml_comp t
                                    else FStar_Parser_AST.tot_comp t) in
                               FStar_Parser_AST.mk_term
                                 (FStar_Parser_AST.Ascribed
                                    (def, t1, tacopt, false))
                                 def.FStar_Parser_AST.range
                                 FStar_Parser_AST.Expr in
                         let def2 =
                           match args1 with
                           | [] -> def1
                           | uu___6 ->
                               let uu___7 =
                                 FStar_Parser_AST.un_curry_abs args1 def1 in
                               FStar_Parser_AST.mk_term uu___7
                                 top.FStar_Parser_AST.range
                                 top.FStar_Parser_AST.level in
                         let uu___6 = desugar_term_aq env1 def2 in
                         (match uu___6 with
                          | (body1, aq) ->
                              let lbname1 =
                                match lbname with
                                | FStar_Pervasives.Inl x ->
                                    FStar_Pervasives.Inl x
                                | FStar_Pervasives.Inr l ->
                                    let uu___7 =
                                      FStar_Syntax_Syntax.lid_and_dd_as_fv l
                                        FStar_Pervasives_Native.None in
                                    FStar_Pervasives.Inr uu___7 in
                              let body2 =
                                if is_rec
                                then
                                  FStar_Syntax_Subst.close rec_bindings1
                                    body1
                                else body1 in
                              let attrs =
                                match attrs_opt with
                                | FStar_Pervasives_Native.None -> []
                                | FStar_Pervasives_Native.Some l ->
                                    FStar_Compiler_List.map
                                      (desugar_term env1) l in
                              let uu___7 =
                                mk_lb
                                  (attrs, lbname1,
                                    (setpos FStar_Syntax_Syntax.tun), body2,
                                    pos) in
                              (uu___7, aq)) in
                   let uu___4 =
                     let uu___5 =
                       FStar_Compiler_List.map2
                         (desugar_one_def (if is_rec then env' else env))
                         fnames1 funs in
                     FStar_Compiler_List.unzip uu___5 in
                   (match uu___4 with
                    | (lbs1, aqss) ->
                        let uu___5 = desugar_term_aq env' body in
                        (match uu___5 with
                         | (body1, aq) ->
                             (if is_rec
                              then
                                FStar_Compiler_List.iter2
                                  (fun uu___7 ->
                                     fun used_marker ->
                                       match uu___7 with
                                       | (_attr_opt, (f, uu___8, uu___9),
                                          uu___10) ->
                                           let uu___11 =
                                             let uu___12 =
                                               FStar_Compiler_Effect.op_Bang
                                                 used_marker in
                                             Prims.op_Negation uu___12 in
                                           if uu___11
                                           then
                                             let uu___12 =
                                               match f with
                                               | FStar_Pervasives.Inl x ->
                                                   let uu___13 =
                                                     FStar_Ident.string_of_id
                                                       x in
                                                   let uu___14 =
                                                     FStar_Ident.range_of_id
                                                       x in
                                                   (uu___13, "Local binding",
                                                     uu___14)
                                               | FStar_Pervasives.Inr l ->
                                                   let uu___13 =
                                                     FStar_Ident.string_of_lid
                                                       l in
                                                   let uu___14 =
                                                     FStar_Ident.range_of_lid
                                                       l in
                                                   (uu___13,
                                                     "Global binding",
                                                     uu___14) in
                                             (match uu___12 with
                                              | (nm, gl, rng) ->
                                                  let uu___13 =
                                                    let uu___14 =
                                                      let uu___15 =
                                                        FStar_Errors_Msg.text
                                                          gl in
                                                      let uu___16 =
                                                        let uu___17 =
                                                          FStar_Pprint.doc_of_string
                                                            nm in
                                                        FStar_Pprint.squotes
                                                          uu___17 in
                                                      let uu___17 =
                                                        FStar_Errors_Msg.text
                                                          "is recursive but not used in its body" in
                                                      FStar_Pprint.surround
                                                        (Prims.of_int (4))
                                                        Prims.int_one uu___15
                                                        uu___16 uu___17 in
                                                    [uu___14] in
                                                  FStar_Errors.log_issue
                                                    FStar_Class_HasRange.hasRange_range
                                                    rng
                                                    FStar_Errors_Codes.Warning_UnusedLetRec
                                                    ()
                                                    (Obj.magic
                                                       FStar_Errors_Msg.is_error_message_list_doc)
                                                    (Obj.magic uu___13))
                                           else ()) funs used_markers1
                              else ();
                              (let uu___7 =
                                 let uu___8 =
                                   let uu___9 =
                                     let uu___10 =
                                       FStar_Syntax_Subst.close rec_bindings1
                                         body1 in
                                     {
                                       FStar_Syntax_Syntax.lbs =
                                         (is_rec, lbs1);
                                       FStar_Syntax_Syntax.body1 = uu___10
                                     } in
                                   FStar_Syntax_Syntax.Tm_let uu___9 in
                                 mk uu___8 in
                               (uu___7,
                                 (FStar_Compiler_List.op_At aq
                                    (FStar_Compiler_List.flatten aqss))))))) in
             let ds_non_rec attrs_opt pat t1 t2 =
               let attrs =
                 match attrs_opt with
                 | FStar_Pervasives_Native.None -> []
                 | FStar_Pervasives_Native.Some l ->
                     FStar_Compiler_List.map (desugar_term env) l in
               let uu___2 = desugar_term_aq env t1 in
               match uu___2 with
               | (t11, aq0) ->
                   let uu___3 =
                     desugar_binding_pat_maybe_top top_level env pat in
                   (match uu___3 with
                    | ((env1, binder, pat1), aqs) ->
                        (check_no_aq aqs;
                         (let uu___5 =
                            match binder with
                            | LetBinder (l, (t, tacopt)) ->
                                (if FStar_Compiler_Util.is_some tacopt
                                 then
                                   (let uu___7 =
                                      FStar_Compiler_Util.must tacopt in
                                    FStar_Errors.log_issue
                                      (FStar_Syntax_Syntax.has_range_syntax
                                         ()) uu___7
                                      FStar_Errors_Codes.Warning_DefinitionNotTranslated
                                      ()
                                      (Obj.magic
                                         FStar_Errors_Msg.is_error_message_string)
                                      (Obj.magic
                                         "Tactic annotation with a value type is not supported yet, try annotating with a computation type; this tactic annotation will be ignored"))
                                 else ();
                                 (let uu___7 = desugar_term_aq env1 t2 in
                                  match uu___7 with
                                  | (body1, aq) ->
                                      let fv =
                                        FStar_Syntax_Syntax.lid_and_dd_as_fv
                                          l FStar_Pervasives_Native.None in
                                      let uu___8 =
                                        let uu___9 =
                                          let uu___10 =
                                            let uu___11 =
                                              let uu___12 =
                                                let uu___13 =
                                                  mk_lb
                                                    (attrs,
                                                      (FStar_Pervasives.Inr
                                                         fv), t, t11,
                                                      (t11.FStar_Syntax_Syntax.pos)) in
                                                [uu___13] in
                                              (false, uu___12) in
                                            {
                                              FStar_Syntax_Syntax.lbs =
                                                uu___11;
                                              FStar_Syntax_Syntax.body1 =
                                                body1
                                            } in
                                          FStar_Syntax_Syntax.Tm_let uu___10 in
                                        mk uu___9 in
                                      (uu___8, aq)))
                            | LocalBinder (x, uu___6, uu___7) ->
                                let uu___8 = desugar_term_aq env1 t2 in
                                (match uu___8 with
                                 | (body1, aq) ->
                                     let body2 =
                                       match pat1 with
                                       | [] -> body1
                                       | uu___9 ->
                                           let uu___10 =
                                             let uu___11 =
                                               let uu___12 =
                                                 FStar_Syntax_Syntax.bv_to_name
                                                   x in
                                               let uu___13 =
                                                 desugar_disjunctive_pattern
                                                   pat1
                                                   FStar_Pervasives_Native.None
                                                   body1 in
                                               {
                                                 FStar_Syntax_Syntax.scrutinee
                                                   = uu___12;
                                                 FStar_Syntax_Syntax.ret_opt
                                                   =
                                                   FStar_Pervasives_Native.None;
                                                 FStar_Syntax_Syntax.brs =
                                                   uu___13;
                                                 FStar_Syntax_Syntax.rc_opt1
                                                   =
                                                   FStar_Pervasives_Native.None
                                               } in
                                             FStar_Syntax_Syntax.Tm_match
                                               uu___11 in
                                           FStar_Syntax_Syntax.mk uu___10
                                             top.FStar_Parser_AST.range in
                                     let uu___9 =
                                       let uu___10 =
                                         let uu___11 =
                                           let uu___12 =
                                             let uu___13 =
                                               let uu___14 =
                                                 mk_lb
                                                   (attrs,
                                                     (FStar_Pervasives.Inl x),
                                                     (x.FStar_Syntax_Syntax.sort),
                                                     t11,
                                                     (t11.FStar_Syntax_Syntax.pos)) in
                                               [uu___14] in
                                             (false, uu___13) in
                                           let uu___13 =
                                             let uu___14 =
                                               let uu___15 =
                                                 FStar_Syntax_Syntax.mk_binder
                                                   x in
                                               [uu___15] in
                                             FStar_Syntax_Subst.close uu___14
                                               body2 in
                                           {
                                             FStar_Syntax_Syntax.lbs =
                                               uu___12;
                                             FStar_Syntax_Syntax.body1 =
                                               uu___13
                                           } in
                                         FStar_Syntax_Syntax.Tm_let uu___11 in
                                       mk uu___10 in
                                     (uu___9, aq)) in
                          match uu___5 with
                          | (tm, aq1) ->
                              (tm, (FStar_Compiler_List.op_At aq0 aq1))))) in
             let uu___2 = FStar_Compiler_List.hd lbs in
             (match uu___2 with
              | (attrs, (head_pat, defn)) ->
                  let uu___3 = is_rec || (is_app_pattern head_pat) in
                  if uu___3
                  then ds_let_rec_or_app ()
                  else ds_non_rec attrs head_pat defn body)
         | FStar_Parser_AST.If
             (e, FStar_Pervasives_Native.Some op, asc_opt, t2, t3) ->
             let var_id =
               FStar_Ident.mk_ident
                 ((Prims.strcat FStar_Ident.reserved_prefix "if_op_head"),
                   (e.FStar_Parser_AST.range)) in
             let var =
               let uu___2 =
                 let uu___3 = FStar_Ident.lid_of_ids [var_id] in
                 FStar_Parser_AST.Var uu___3 in
               FStar_Parser_AST.mk_term uu___2 e.FStar_Parser_AST.range
                 FStar_Parser_AST.Expr in
             let pat =
               FStar_Parser_AST.mk_pattern
                 (FStar_Parser_AST.PatVar
                    (var_id, FStar_Pervasives_Native.None, []))
                 e.FStar_Parser_AST.range in
             let if_ =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.If
                    (var, FStar_Pervasives_Native.None, asc_opt, t2, t3))
                 top.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             let t =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.LetOperator ([(op, pat, e)], if_))
                 e.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             desugar_term_aq env t
         | FStar_Parser_AST.If
             (t1, FStar_Pervasives_Native.None, asc_opt, t2, t3) ->
             let x =
               let uu___2 = tun_r t3.FStar_Parser_AST.range in
               FStar_Syntax_Syntax.new_bv
                 (FStar_Pervasives_Native.Some (t3.FStar_Parser_AST.range))
                 uu___2 in
             let t_bool =
               let uu___2 =
                 let uu___3 =
                   FStar_Syntax_Syntax.lid_and_dd_as_fv
                     FStar_Parser_Const.bool_lid FStar_Pervasives_Native.None in
                 FStar_Syntax_Syntax.Tm_fvar uu___3 in
               mk uu___2 in
             let uu___2 = desugar_term_aq env t1 in
             (match uu___2 with
              | (t1', aq1) ->
                  let t1'1 =
                    FStar_Syntax_Util.ascribe t1'
                      ((FStar_Pervasives.Inl t_bool),
                        FStar_Pervasives_Native.None, false) in
                  let uu___3 = desugar_match_returns env t1'1 asc_opt in
                  (match uu___3 with
                   | (asc_opt1, aq0) ->
                       let uu___4 = desugar_term_aq env t2 in
                       (match uu___4 with
                        | (t2', aq2) ->
                            let uu___5 = desugar_term_aq env t3 in
                            (match uu___5 with
                             | (t3', aq3) ->
                                 let uu___6 =
                                   let uu___7 =
                                     let uu___8 =
                                       let uu___9 =
                                         let uu___10 =
                                           let uu___11 =
                                             FStar_Syntax_Syntax.withinfo
                                               (FStar_Syntax_Syntax.Pat_constant
                                                  (FStar_Const.Const_bool
                                                     true))
                                               t1.FStar_Parser_AST.range in
                                           (uu___11,
                                             FStar_Pervasives_Native.None,
                                             t2') in
                                         let uu___11 =
                                           let uu___12 =
                                             let uu___13 =
                                               FStar_Syntax_Syntax.withinfo
                                                 (FStar_Syntax_Syntax.Pat_var
                                                    x)
                                                 t1.FStar_Parser_AST.range in
                                             (uu___13,
                                               FStar_Pervasives_Native.None,
                                               t3') in
                                           [uu___12] in
                                         uu___10 :: uu___11 in
                                       {
                                         FStar_Syntax_Syntax.scrutinee = t1'1;
                                         FStar_Syntax_Syntax.ret_opt =
                                           asc_opt1;
                                         FStar_Syntax_Syntax.brs = uu___9;
                                         FStar_Syntax_Syntax.rc_opt1 =
                                           FStar_Pervasives_Native.None
                                       } in
                                     FStar_Syntax_Syntax.Tm_match uu___8 in
                                   mk uu___7 in
                                 (uu___6, (join_aqs [aq1; aq0; aq2; aq3]))))))
         | FStar_Parser_AST.TryWith (e, branches) ->
             let r = top.FStar_Parser_AST.range in
             let handler = FStar_Parser_AST.mk_function branches r r in
             let body =
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     FStar_Parser_AST.mk_pattern
                       (FStar_Parser_AST.PatConst FStar_Const.Const_unit) r in
                   (uu___4, FStar_Pervasives_Native.None, e) in
                 [uu___3] in
               FStar_Parser_AST.mk_function uu___2 r r in
             let try_with_lid = FStar_Ident.lid_of_path ["try_with"] r in
             let try_with =
               FStar_Parser_AST.mk_term (FStar_Parser_AST.Var try_with_lid) r
                 FStar_Parser_AST.Expr in
             let a1 =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.App
                    (try_with, body, FStar_Parser_AST.Nothing)) r
                 top.FStar_Parser_AST.level in
             let a2 =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.App
                    (a1, handler, FStar_Parser_AST.Nothing)) r
                 top.FStar_Parser_AST.level in
             desugar_term_aq env a2
         | FStar_Parser_AST.Match
             (e, FStar_Pervasives_Native.Some op, topt, branches) ->
             let var_id =
               FStar_Ident.mk_ident
                 ((Prims.strcat FStar_Ident.reserved_prefix "match_op_head"),
                   (e.FStar_Parser_AST.range)) in
             let var =
               let uu___2 =
                 let uu___3 = FStar_Ident.lid_of_ids [var_id] in
                 FStar_Parser_AST.Var uu___3 in
               FStar_Parser_AST.mk_term uu___2 e.FStar_Parser_AST.range
                 FStar_Parser_AST.Expr in
             let pat =
               FStar_Parser_AST.mk_pattern
                 (FStar_Parser_AST.PatVar
                    (var_id, FStar_Pervasives_Native.None, []))
                 e.FStar_Parser_AST.range in
             let mt =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Match
                    (var, FStar_Pervasives_Native.None, topt, branches))
                 top.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             let t =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.LetOperator ([(op, pat, e)], mt))
                 e.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             desugar_term_aq env t
         | FStar_Parser_AST.Match
             (e, FStar_Pervasives_Native.None, topt, branches) ->
             let desugar_branch uu___2 =
               match uu___2 with
               | (pat, wopt, b) ->
                   let uu___3 = desugar_match_pat env pat in
                   (match uu___3 with
                    | ((env1, pat1), aqP) ->
                        let wopt1 =
                          match wopt with
                          | FStar_Pervasives_Native.None ->
                              FStar_Pervasives_Native.None
                          | FStar_Pervasives_Native.Some e1 ->
                              let uu___4 = desugar_term env1 e1 in
                              FStar_Pervasives_Native.Some uu___4 in
                        let uu___4 = desugar_term_aq env1 b in
                        (match uu___4 with
                         | (b1, aqB) ->
                             let uu___5 =
                               desugar_disjunctive_pattern pat1 wopt1 b1 in
                             (uu___5, (FStar_Compiler_List.op_At aqP aqB)))) in
             let uu___2 = desugar_term_aq env e in
             (match uu___2 with
              | (e1, aq) ->
                  let uu___3 = desugar_match_returns env e1 topt in
                  (match uu___3 with
                   | (asc_opt, aq0) ->
                       let uu___4 =
                         let uu___5 =
                           let uu___6 =
                             FStar_Compiler_List.map desugar_branch branches in
                           FStar_Compiler_List.unzip uu___6 in
                         match uu___5 with
                         | (x, y) -> ((FStar_Compiler_List.flatten x), y) in
                       (match uu___4 with
                        | (brs, aqs) ->
                            let uu___5 =
                              mk
                                (FStar_Syntax_Syntax.Tm_match
                                   {
                                     FStar_Syntax_Syntax.scrutinee = e1;
                                     FStar_Syntax_Syntax.ret_opt = asc_opt;
                                     FStar_Syntax_Syntax.brs = brs;
                                     FStar_Syntax_Syntax.rc_opt1 =
                                       FStar_Pervasives_Native.None
                                   }) in
                            (uu___5, (join_aqs (aq :: aq0 :: aqs))))))
         | FStar_Parser_AST.Ascribed (e, t, tac_opt, use_eq) ->
             let uu___2 = desugar_ascription env t tac_opt use_eq in
             (match uu___2 with
              | (asc, aq0) ->
                  let uu___3 = desugar_term_aq env e in
                  (match uu___3 with
                   | (e1, aq) ->
                       let uu___4 =
                         mk
                           (FStar_Syntax_Syntax.Tm_ascribed
                              {
                                FStar_Syntax_Syntax.tm = e1;
                                FStar_Syntax_Syntax.asc = asc;
                                FStar_Syntax_Syntax.eff_opt =
                                  FStar_Pervasives_Native.None
                              }) in
                       (uu___4, (FStar_Compiler_List.op_At aq0 aq))))
         | FStar_Parser_AST.Record (uu___2, []) ->
             FStar_Errors.raise_error FStar_Parser_AST.hasRange_term top
               FStar_Errors_Codes.Fatal_UnexpectedEmptyRecord ()
               (Obj.magic FStar_Errors_Msg.is_error_message_string)
               (Obj.magic "Unexpected empty record")
         | FStar_Parser_AST.Record (eopt, fields) ->
             let record_opt =
               let uu___2 = FStar_Compiler_List.hd fields in
               match uu___2 with
               | (f, uu___3) ->
                   FStar_Syntax_DsEnv.try_lookup_record_by_field_name env f in
             let uu___2 =
               let uu___3 =
                 FStar_Compiler_List.map
                   (fun uu___4 ->
                      match uu___4 with
                      | (fn, fval) ->
                          let uu___5 = desugar_term_aq env fval in
                          (match uu___5 with
                           | (fval1, aq) -> ((fn, fval1), aq))) fields in
               FStar_Compiler_List.unzip uu___3 in
             (match uu___2 with
              | (fields1, aqs) ->
                  let uu___3 = FStar_Compiler_List.unzip fields1 in
                  (match uu___3 with
                   | (field_names, assignments) ->
                       let args =
                         FStar_Compiler_List.map
                           (fun f -> (f, FStar_Pervasives_Native.None))
                           assignments in
                       let aqs1 = FStar_Compiler_List.flatten aqs in
                       let uc =
                         match record_opt with
                         | FStar_Pervasives_Native.None ->
                             {
                               FStar_Syntax_Syntax.uc_base_term =
                                 (FStar_Compiler_Option.isSome eopt);
                               FStar_Syntax_Syntax.uc_typename =
                                 FStar_Pervasives_Native.None;
                               FStar_Syntax_Syntax.uc_fields = field_names
                             }
                         | FStar_Pervasives_Native.Some record ->
                             let uu___4 =
                               qualify_field_names
                                 record.FStar_Syntax_DsEnv.typename
                                 field_names in
                             {
                               FStar_Syntax_Syntax.uc_base_term =
                                 (FStar_Compiler_Option.isSome eopt);
                               FStar_Syntax_Syntax.uc_typename =
                                 (FStar_Pervasives_Native.Some
                                    (record.FStar_Syntax_DsEnv.typename));
                               FStar_Syntax_Syntax.uc_fields = uu___4
                             } in
                       let head =
                         let lid =
                           FStar_Ident.lid_of_path ["__dummy__"]
                             top.FStar_Parser_AST.range in
                         FStar_Syntax_Syntax.fvar_with_dd lid
                           (FStar_Pervasives_Native.Some
                              (FStar_Syntax_Syntax.Unresolved_constructor uc)) in
                       let mk_result args1 =
                         FStar_Syntax_Syntax.mk_Tm_app head args1
                           top.FStar_Parser_AST.range in
                       (match eopt with
                        | FStar_Pervasives_Native.None ->
                            let uu___4 = mk_result args in (uu___4, aqs1)
                        | FStar_Pervasives_Native.Some e ->
                            let uu___4 = desugar_term_aq env e in
                            (match uu___4 with
                             | (e1, aq) ->
                                 let tm =
                                   let uu___5 =
                                     let uu___6 =
                                       FStar_Syntax_Subst.compress e1 in
                                     uu___6.FStar_Syntax_Syntax.n in
                                   match uu___5 with
                                   | FStar_Syntax_Syntax.Tm_name uu___6 ->
                                       mk_result
                                         ((e1, FStar_Pervasives_Native.None)
                                         :: args)
                                   | FStar_Syntax_Syntax.Tm_fvar uu___6 ->
                                       mk_result
                                         ((e1, FStar_Pervasives_Native.None)
                                         :: args)
                                   | uu___6 ->
                                       let x =
                                         FStar_Ident.gen
                                           e1.FStar_Syntax_Syntax.pos in
                                       let uu___7 =
                                         FStar_Syntax_DsEnv.push_bv env x in
                                       (match uu___7 with
                                        | (env', bv_x) ->
                                            let nm =
                                              FStar_Syntax_Syntax.bv_to_name
                                                bv_x in
                                            let body =
                                              mk_result
                                                ((nm,
                                                   FStar_Pervasives_Native.None)
                                                :: args) in
                                            let body1 =
                                              let uu___8 =
                                                let uu___9 =
                                                  FStar_Syntax_Syntax.mk_binder
                                                    bv_x in
                                                [uu___9] in
                                              FStar_Syntax_Subst.close uu___8
                                                body in
                                            let lb =
                                              mk_lb
                                                ([],
                                                  (FStar_Pervasives.Inl bv_x),
                                                  FStar_Syntax_Syntax.tun,
                                                  e1,
                                                  (e1.FStar_Syntax_Syntax.pos)) in
                                            mk
                                              (FStar_Syntax_Syntax.Tm_let
                                                 {
                                                   FStar_Syntax_Syntax.lbs =
                                                     (false, [lb]);
                                                   FStar_Syntax_Syntax.body1
                                                     = body1
                                                 })) in
                                 (tm, (FStar_Compiler_List.op_At aq aqs1))))))
         | FStar_Parser_AST.Project (e, f) ->
             let uu___2 = desugar_term_aq env e in
             (match uu___2 with
              | (e1, s) ->
                  let head =
                    let uu___3 =
                      FStar_Syntax_DsEnv.try_lookup_dc_by_field_name env f in
                    match uu___3 with
                    | FStar_Pervasives_Native.None ->
                        FStar_Syntax_Syntax.fvar_with_dd f
                          (FStar_Pervasives_Native.Some
                             (FStar_Syntax_Syntax.Unresolved_projector
                                FStar_Pervasives_Native.None))
                    | FStar_Pervasives_Native.Some (constrname, is_rec) ->
                        let projname =
                          let uu___4 = FStar_Ident.ident_of_lid f in
                          FStar_Syntax_Util.mk_field_projector_name_from_ident
                            constrname uu___4 in
                        let qual =
                          if is_rec
                          then
                            let uu___4 =
                              let uu___5 =
                                let uu___6 = FStar_Ident.ident_of_lid f in
                                (constrname, uu___6) in
                              FStar_Syntax_Syntax.Record_projector uu___5 in
                            FStar_Pervasives_Native.Some uu___4
                          else FStar_Pervasives_Native.None in
                        let candidate_projector =
                          let uu___4 =
                            FStar_Ident.set_lid_range projname
                              top.FStar_Parser_AST.range in
                          FStar_Syntax_Syntax.lid_and_dd_as_fv uu___4 qual in
                        let qual1 =
                          FStar_Syntax_Syntax.Unresolved_projector
                            (FStar_Pervasives_Native.Some candidate_projector) in
                        let f1 =
                          let uu___4 = qualify_field_names constrname [f] in
                          FStar_Compiler_List.hd uu___4 in
                        FStar_Syntax_Syntax.fvar_with_dd f1
                          (FStar_Pervasives_Native.Some qual1) in
                  let uu___3 =
                    let uu___4 =
                      let uu___5 =
                        let uu___6 =
                          let uu___7 = FStar_Syntax_Syntax.as_arg e1 in
                          [uu___7] in
                        {
                          FStar_Syntax_Syntax.hd = head;
                          FStar_Syntax_Syntax.args = uu___6
                        } in
                      FStar_Syntax_Syntax.Tm_app uu___5 in
                    mk uu___4 in
                  (uu___3, s))
         | FStar_Parser_AST.NamedTyp (n, e) ->
             (FStar_Errors.log_issue FStar_Ident.hasrange_ident n
                FStar_Errors_Codes.Warning_IgnoredBinding ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic "This name is being ignored");
              desugar_term_aq env e)
         | FStar_Parser_AST.Paren e ->
             FStar_Compiler_Effect.failwith "impossible"
         | FStar_Parser_AST.VQuote e ->
             let uu___2 =
               let uu___3 =
                 let uu___4 = desugar_vquote env e top.FStar_Parser_AST.range in
                 FStar_Syntax_Util.exp_string uu___4 in
               {
                 FStar_Syntax_Syntax.n = (uu___3.FStar_Syntax_Syntax.n);
                 FStar_Syntax_Syntax.pos = (e.FStar_Parser_AST.range);
                 FStar_Syntax_Syntax.vars = (uu___3.FStar_Syntax_Syntax.vars);
                 FStar_Syntax_Syntax.hash_code =
                   (uu___3.FStar_Syntax_Syntax.hash_code)
               } in
             (uu___2, noaqs)
         | FStar_Parser_AST.Quote (e, FStar_Parser_AST.Static) ->
             let uu___2 = desugar_term_aq env e in
             (match uu___2 with
              | (tm, vts) ->
                  let vt_binders =
                    FStar_Compiler_List.map
                      (fun uu___3 ->
                         match uu___3 with
                         | (bv, _tm) -> FStar_Syntax_Syntax.mk_binder bv) vts in
                  let vt_tms =
                    FStar_Compiler_List.map FStar_Pervasives_Native.snd vts in
                  let tm1 = FStar_Syntax_Subst.close vt_binders tm in
                  ((let fvs = FStar_Syntax_Free.names tm1 in
                    let uu___4 =
                      let uu___5 =
                        FStar_Class_Setlike.is_empty ()
                          (Obj.magic
                             (FStar_Compiler_FlatSet.setlike_flat_set
                                FStar_Syntax_Syntax.ord_bv)) (Obj.magic fvs) in
                      Prims.op_Negation uu___5 in
                    if uu___4
                    then
                      let uu___5 =
                        let uu___6 =
                          FStar_Class_Show.show
                            (FStar_Compiler_FlatSet.showable_set
                               FStar_Syntax_Syntax.ord_bv
                               FStar_Syntax_Print.showable_bv) fvs in
                        FStar_Compiler_Util.format1
                          "Static quotation refers to external variables: %s"
                          uu___6 in
                      FStar_Errors.raise_error FStar_Parser_AST.hasRange_term
                        e FStar_Errors_Codes.Fatal_MissingFieldInRecord ()
                        (Obj.magic FStar_Errors_Msg.is_error_message_string)
                        (Obj.magic uu___5)
                    else ());
                   (match () with
                    | () ->
                        let qi =
                          {
                            FStar_Syntax_Syntax.qkind =
                              FStar_Syntax_Syntax.Quote_static;
                            FStar_Syntax_Syntax.antiquotations =
                              (Prims.int_zero, vt_tms)
                          } in
                        let uu___4 =
                          mk (FStar_Syntax_Syntax.Tm_quoted (tm1, qi)) in
                        (uu___4, noaqs))))
         | FStar_Parser_AST.Antiquote e ->
             let bv =
               FStar_Syntax_Syntax.new_bv
                 (FStar_Pervasives_Native.Some (e.FStar_Parser_AST.range))
                 FStar_Syntax_Syntax.tun in
             let tm = desugar_term env e in
             let uu___2 = FStar_Syntax_Syntax.bv_to_name bv in
             (uu___2, [(bv, tm)])
         | FStar_Parser_AST.Quote (e, FStar_Parser_AST.Dynamic) ->
             let qi =
               {
                 FStar_Syntax_Syntax.qkind =
                   FStar_Syntax_Syntax.Quote_dynamic;
                 FStar_Syntax_Syntax.antiquotations = (Prims.int_zero, [])
               } in
             let uu___2 =
               let uu___3 =
                 let uu___4 = let uu___5 = desugar_term env e in (uu___5, qi) in
                 FStar_Syntax_Syntax.Tm_quoted uu___4 in
               mk uu___3 in
             (uu___2, noaqs)
         | FStar_Parser_AST.CalcProof (rel, init_expr, steps) ->
             let is_impl rel1 =
               let is_impl_t t =
                 match t.FStar_Syntax_Syntax.n with
                 | FStar_Syntax_Syntax.Tm_fvar fv ->
                     FStar_Syntax_Syntax.fv_eq_lid fv
                       FStar_Parser_Const.imp_lid
                 | uu___2 -> false in
               let uu___2 =
                 let uu___3 = unparen rel1 in uu___3.FStar_Parser_AST.tm in
               match uu___2 with
               | FStar_Parser_AST.Op (id, uu___3) ->
                   let uu___4 = op_as_term env (Prims.of_int (2)) id in
                   (match uu___4 with
                    | FStar_Pervasives_Native.Some t -> is_impl_t t
                    | FStar_Pervasives_Native.None -> false)
               | FStar_Parser_AST.Var lid ->
                   let uu___3 = desugar_name' (fun x -> x) env true lid in
                   (match uu___3 with
                    | FStar_Pervasives_Native.Some t -> is_impl_t t
                    | FStar_Pervasives_Native.None -> false)
               | FStar_Parser_AST.Tvar id ->
                   let uu___3 = FStar_Syntax_DsEnv.try_lookup_id env id in
                   (match uu___3 with
                    | FStar_Pervasives_Native.Some t -> is_impl_t t
                    | FStar_Pervasives_Native.None -> false)
               | uu___3 -> false in
             let eta_and_annot rel1 =
               let x = FStar_Ident.gen' "x" rel1.FStar_Parser_AST.range in
               let y = FStar_Ident.gen' "y" rel1.FStar_Parser_AST.range in
               let xt =
                 FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar x)
                   rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr in
               let yt =
                 FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar y)
                   rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr in
               let pats =
                 let uu___2 =
                   FStar_Parser_AST.mk_pattern
                     (FStar_Parser_AST.PatVar
                        (x, FStar_Pervasives_Native.None, []))
                     rel1.FStar_Parser_AST.range in
                 let uu___3 =
                   let uu___4 =
                     FStar_Parser_AST.mk_pattern
                       (FStar_Parser_AST.PatVar
                          (y, FStar_Pervasives_Native.None, []))
                       rel1.FStar_Parser_AST.range in
                   [uu___4] in
                 uu___2 :: uu___3 in
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     let uu___5 =
                       let uu___6 =
                         let uu___7 =
                           FStar_Parser_AST.mkApp rel1
                             [(xt, FStar_Parser_AST.Nothing);
                             (yt, FStar_Parser_AST.Nothing)]
                             rel1.FStar_Parser_AST.range in
                         let uu___8 =
                           let uu___9 =
                             let uu___10 = FStar_Ident.lid_of_str "Type0" in
                             FStar_Parser_AST.Name uu___10 in
                           FStar_Parser_AST.mk_term uu___9
                             rel1.FStar_Parser_AST.range
                             FStar_Parser_AST.Expr in
                         (uu___7, uu___8, FStar_Pervasives_Native.None,
                           false) in
                       FStar_Parser_AST.Ascribed uu___6 in
                     FStar_Parser_AST.mk_term uu___5
                       rel1.FStar_Parser_AST.range FStar_Parser_AST.Expr in
                   (pats, uu___4) in
                 FStar_Parser_AST.Abs uu___3 in
               FStar_Parser_AST.mk_term uu___2 rel1.FStar_Parser_AST.range
                 FStar_Parser_AST.Expr in
             let rel1 = eta_and_annot rel in
             let wild r =
               FStar_Parser_AST.mk_term FStar_Parser_AST.Wild r
                 FStar_Parser_AST.Expr in
             let init =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Var FStar_Parser_Const.calc_init_lid)
                 init_expr.FStar_Parser_AST.range FStar_Parser_AST.Expr in
             let push_impl r =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Var FStar_Parser_Const.calc_push_impl_lid)
                 r FStar_Parser_AST.Expr in
             let last_expr =
               let uu___2 = FStar_Compiler_List.last_opt steps in
               match uu___2 with
               | FStar_Pervasives_Native.Some (FStar_Parser_AST.CalcStep
                   (uu___3, uu___4, last_expr1)) -> last_expr1
               | FStar_Pervasives_Native.None -> init_expr in
             let step r =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Var FStar_Parser_Const.calc_step_lid) r
                 FStar_Parser_AST.Expr in
             let finish =
               let uu___2 =
                 FStar_Parser_AST.mk_term
                   (FStar_Parser_AST.Var FStar_Parser_Const.calc_finish_lid)
                   top.FStar_Parser_AST.range FStar_Parser_AST.Expr in
               FStar_Parser_AST.mkApp uu___2
                 [(rel1, FStar_Parser_AST.Nothing)]
                 top.FStar_Parser_AST.range in
             let e =
               FStar_Parser_AST.mkApp init
                 [(init_expr, FStar_Parser_AST.Nothing)]
                 init_expr.FStar_Parser_AST.range in
             let uu___2 =
               FStar_Compiler_List.fold_left
                 (fun uu___3 ->
                    fun uu___4 ->
                      match (uu___3, uu___4) with
                      | ((e1, prev), FStar_Parser_AST.CalcStep
                         (rel2, just, next_expr)) ->
                          let just1 =
                            let uu___5 = is_impl rel2 in
                            if uu___5
                            then
                              let uu___6 =
                                push_impl just.FStar_Parser_AST.range in
                              let uu___7 =
                                let uu___8 =
                                  let uu___9 = FStar_Parser_AST.thunk just in
                                  (uu___9, FStar_Parser_AST.Nothing) in
                                [uu___8] in
                              FStar_Parser_AST.mkApp uu___6 uu___7
                                just.FStar_Parser_AST.range
                            else just in
                          let pf =
                            let uu___5 = step rel2.FStar_Parser_AST.range in
                            let uu___6 =
                              let uu___7 =
                                let uu___8 = wild rel2.FStar_Parser_AST.range in
                                (uu___8, FStar_Parser_AST.Hash) in
                              let uu___8 =
                                let uu___9 =
                                  let uu___10 =
                                    let uu___11 =
                                      let uu___12 = eta_and_annot rel2 in
                                      (uu___12, FStar_Parser_AST.Nothing) in
                                    let uu___12 =
                                      let uu___13 =
                                        let uu___14 =
                                          let uu___15 =
                                            FStar_Parser_AST.thunk e1 in
                                          (uu___15, FStar_Parser_AST.Nothing) in
                                        let uu___15 =
                                          let uu___16 =
                                            let uu___17 =
                                              FStar_Parser_AST.thunk just1 in
                                            (uu___17,
                                              FStar_Parser_AST.Nothing) in
                                          [uu___16] in
                                        uu___14 :: uu___15 in
                                      (next_expr, FStar_Parser_AST.Nothing)
                                        :: uu___13 in
                                    uu___11 :: uu___12 in
                                  (prev, FStar_Parser_AST.Hash) :: uu___10 in
                                (init_expr, FStar_Parser_AST.Hash) :: uu___9 in
                              uu___7 :: uu___8 in
                            FStar_Parser_AST.mkApp uu___5 uu___6
                              FStar_Compiler_Range_Type.dummyRange in
                          (pf, next_expr)) (e, init_expr) steps in
             (match uu___2 with
              | (e1, uu___3) ->
                  let e2 =
                    let uu___4 =
                      let uu___5 =
                        let uu___6 =
                          let uu___7 =
                            let uu___8 = FStar_Parser_AST.thunk e1 in
                            (uu___8, FStar_Parser_AST.Nothing) in
                          [uu___7] in
                        (last_expr, FStar_Parser_AST.Hash) :: uu___6 in
                      (init_expr, FStar_Parser_AST.Hash) :: uu___5 in
                    FStar_Parser_AST.mkApp finish uu___4
                      top.FStar_Parser_AST.range in
                  desugar_term_maybe_top top_level env e2)
         | FStar_Parser_AST.IntroForall (bs, p, e) ->
             let uu___2 = desugar_binders env bs in
             (match uu___2 with
              | (env', bs1) ->
                  let p1 = desugar_term env' p in
                  let e1 = desugar_term env' e in
                  let mk_forall_intro t p2 pf =
                    let head =
                      let uu___3 =
                        FStar_Syntax_Syntax.lid_and_dd_as_fv
                          FStar_Parser_Const.forall_intro_lid
                          FStar_Pervasives_Native.None in
                      FStar_Syntax_Syntax.fv_to_tm uu___3 in
                    let args =
                      [(t, FStar_Pervasives_Native.None);
                      (p2, FStar_Pervasives_Native.None);
                      (pf, FStar_Pervasives_Native.None)] in
                    FStar_Syntax_Syntax.mk_Tm_app head args
                      top.FStar_Parser_AST.range in
                  let rec aux bs2 =
                    match bs2 with
                    | [] ->
                        let sq_p =
                          FStar_Syntax_Util.mk_squash
                            FStar_Syntax_Syntax.U_unknown p1 in
                        FStar_Syntax_Util.ascribe e1
                          ((FStar_Pervasives.Inl sq_p),
                            FStar_Pervasives_Native.None, false)
                    | b::bs3 ->
                        let tail = aux bs3 in
                        let x = unqual_bv_of_binder b in
                        let uu___3 =
                          let uu___4 =
                            FStar_Syntax_Util.close_forall_no_univs bs3 p1 in
                          FStar_Syntax_Util.abs [b] uu___4
                            FStar_Pervasives_Native.None in
                        let uu___4 =
                          FStar_Syntax_Util.abs [b] tail
                            FStar_Pervasives_Native.None in
                        mk_forall_intro x.FStar_Syntax_Syntax.sort uu___3
                          uu___4 in
                  let uu___3 = aux bs1 in (uu___3, noaqs))
         | FStar_Parser_AST.IntroExists (bs, p, vs, e) ->
             let uu___2 = desugar_binders env bs in
             (match uu___2 with
              | (env', bs1) ->
                  let p1 = desugar_term env' p in
                  let vs1 = FStar_Compiler_List.map (desugar_term env) vs in
                  let e1 = desugar_term env e in
                  let mk_exists_intro t p2 v e2 =
                    let head =
                      let uu___3 =
                        FStar_Syntax_Syntax.lid_and_dd_as_fv
                          FStar_Parser_Const.exists_intro_lid
                          FStar_Pervasives_Native.None in
                      FStar_Syntax_Syntax.fv_to_tm uu___3 in
                    let args =
                      let uu___3 =
                        let uu___4 =
                          let uu___5 =
                            let uu___6 =
                              let uu___7 = mk_thunk e2 in
                              (uu___7, FStar_Pervasives_Native.None) in
                            [uu___6] in
                          (v, FStar_Pervasives_Native.None) :: uu___5 in
                        (p2, FStar_Pervasives_Native.None) :: uu___4 in
                      (t, FStar_Pervasives_Native.None) :: uu___3 in
                    FStar_Syntax_Syntax.mk_Tm_app head args
                      top.FStar_Parser_AST.range in
                  let rec aux bs2 vs2 sub token =
                    match (bs2, vs2) with
                    | ([], []) -> token
                    | (b::bs3, v::vs3) ->
                        let x = unqual_bv_of_binder b in
                        let token1 =
                          let uu___3 =
                            FStar_Syntax_Subst.subst_binders
                              ((FStar_Syntax_Syntax.NT (x, v)) :: sub) bs3 in
                          aux uu___3 vs3 ((FStar_Syntax_Syntax.NT (x, v)) ::
                            sub) token in
                        let token2 =
                          let uu___3 =
                            let uu___4 =
                              let uu___5 = FStar_Syntax_Subst.subst sub p1 in
                              FStar_Syntax_Util.close_exists_no_univs bs3
                                uu___5 in
                            FStar_Syntax_Util.abs [b] uu___4
                              FStar_Pervasives_Native.None in
                          mk_exists_intro x.FStar_Syntax_Syntax.sort uu___3 v
                            token1 in
                        token2
                    | uu___3 ->
                        FStar_Errors.raise_error
                          FStar_Parser_AST.hasRange_term top
                          FStar_Errors_Codes.Fatal_UnexpectedTerm ()
                          (Obj.magic FStar_Errors_Msg.is_error_message_string)
                          (Obj.magic
                             "Unexpected number of instantiations in _intro_ exists") in
                  let uu___3 = aux bs1 vs1 [] e1 in (uu___3, noaqs))
         | FStar_Parser_AST.IntroImplies (p, q, x, e) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let uu___2 = desugar_binders env [x] in
             (match uu___2 with
              | (env', x1::[]) ->
                  let e1 = desugar_term env' e in
                  let head =
                    let uu___3 =
                      FStar_Syntax_Syntax.lid_and_dd_as_fv
                        FStar_Parser_Const.implies_intro_lid
                        FStar_Pervasives_Native.None in
                    FStar_Syntax_Syntax.fv_to_tm uu___3 in
                  let args =
                    let uu___3 =
                      let uu___4 =
                        let uu___5 = mk_thunk q1 in
                        (uu___5, FStar_Pervasives_Native.None) in
                      let uu___5 =
                        let uu___6 =
                          let uu___7 =
                            FStar_Syntax_Util.abs [x1] e1
                              FStar_Pervasives_Native.None in
                          (uu___7, FStar_Pervasives_Native.None) in
                        [uu___6] in
                      uu___4 :: uu___5 in
                    (p1, FStar_Pervasives_Native.None) :: uu___3 in
                  let uu___3 =
                    FStar_Syntax_Syntax.mk_Tm_app head args
                      top.FStar_Parser_AST.range in
                  (uu___3, noaqs))
         | FStar_Parser_AST.IntroOr (lr, p, q, e) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let e1 = desugar_term env e in
             let lid =
               if lr
               then FStar_Parser_Const.or_intro_left_lid
               else FStar_Parser_Const.or_intro_right_lid in
             let head =
               let uu___2 =
                 FStar_Syntax_Syntax.lid_and_dd_as_fv lid
                   FStar_Pervasives_Native.None in
               FStar_Syntax_Syntax.fv_to_tm uu___2 in
             let args =
               let uu___2 =
                 let uu___3 =
                   let uu___4 = mk_thunk q1 in
                   (uu___4, FStar_Pervasives_Native.None) in
                 let uu___4 =
                   let uu___5 =
                     let uu___6 = mk_thunk e1 in
                     (uu___6, FStar_Pervasives_Native.None) in
                   [uu___5] in
                 uu___3 :: uu___4 in
               (p1, FStar_Pervasives_Native.None) :: uu___2 in
             let uu___2 =
               FStar_Syntax_Syntax.mk_Tm_app head args
                 top.FStar_Parser_AST.range in
             (uu___2, noaqs)
         | FStar_Parser_AST.IntroAnd (p, q, e1, e2) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let e11 = desugar_term env e1 in
             let e21 = desugar_term env e2 in
             let head =
               let uu___2 =
                 FStar_Syntax_Syntax.lid_and_dd_as_fv
                   FStar_Parser_Const.and_intro_lid
                   FStar_Pervasives_Native.None in
               FStar_Syntax_Syntax.fv_to_tm uu___2 in
             let args =
               let uu___2 =
                 let uu___3 =
                   let uu___4 = mk_thunk q1 in
                   (uu___4, FStar_Pervasives_Native.None) in
                 let uu___4 =
                   let uu___5 =
                     let uu___6 = mk_thunk e11 in
                     (uu___6, FStar_Pervasives_Native.None) in
                   let uu___6 =
                     let uu___7 =
                       let uu___8 = mk_thunk e21 in
                       (uu___8, FStar_Pervasives_Native.None) in
                     [uu___7] in
                   uu___5 :: uu___6 in
                 uu___3 :: uu___4 in
               (p1, FStar_Pervasives_Native.None) :: uu___2 in
             let uu___2 =
               FStar_Syntax_Syntax.mk_Tm_app head args
                 top.FStar_Parser_AST.range in
             (uu___2, noaqs)
         | FStar_Parser_AST.ElimForall (bs, p, vs) ->
             let uu___2 = desugar_binders env bs in
             (match uu___2 with
              | (env', bs1) ->
                  let p1 = desugar_term env' p in
                  let vs1 = FStar_Compiler_List.map (desugar_term env) vs in
                  let mk_forall_elim a p2 v tok =
                    let head =
                      let uu___3 =
                        FStar_Syntax_Syntax.lid_and_dd_as_fv
                          FStar_Parser_Const.forall_elim_lid
                          FStar_Pervasives_Native.None in
                      FStar_Syntax_Syntax.fv_to_tm uu___3 in
                    let args =
                      let uu___3 =
                        let uu___4 =
                          FStar_Syntax_Syntax.as_aqual_implicit true in
                        (a, uu___4) in
                      let uu___4 =
                        let uu___5 =
                          let uu___6 =
                            FStar_Syntax_Syntax.as_aqual_implicit true in
                          (p2, uu___6) in
                        [uu___5;
                        (v, FStar_Pervasives_Native.None);
                        (tok, FStar_Pervasives_Native.None)] in
                      uu___3 :: uu___4 in
                    FStar_Syntax_Syntax.mk_Tm_app head args
                      tok.FStar_Syntax_Syntax.pos in
                  let rec aux bs2 vs2 sub token =
                    match (bs2, vs2) with
                    | ([], []) -> token
                    | (b::bs3, v::vs3) ->
                        let x = unqual_bv_of_binder b in
                        let token1 =
                          let uu___3 =
                            let uu___4 =
                              let uu___5 = FStar_Syntax_Subst.subst sub p1 in
                              FStar_Syntax_Util.close_forall_no_univs bs3
                                uu___5 in
                            FStar_Syntax_Util.abs [b] uu___4
                              FStar_Pervasives_Native.None in
                          mk_forall_elim x.FStar_Syntax_Syntax.sort uu___3 v
                            token in
                        let sub1 = (FStar_Syntax_Syntax.NT (x, v)) :: sub in
                        let uu___3 =
                          FStar_Syntax_Subst.subst_binders sub1 bs3 in
                        aux uu___3 vs3 sub1 token1
                    | uu___3 ->
                        FStar_Errors.raise_error
                          FStar_Parser_AST.hasRange_term top
                          FStar_Errors_Codes.Fatal_UnexpectedTerm ()
                          (Obj.magic FStar_Errors_Msg.is_error_message_string)
                          (Obj.magic
                             "Unexpected number of instantiations in _elim_forall_") in
                  let range =
                    FStar_Compiler_List.fold_right
                      (fun bs2 ->
                         fun r ->
                           let uu___3 =
                             FStar_Syntax_Syntax.range_of_bv
                               bs2.FStar_Syntax_Syntax.binder_bv in
                           FStar_Compiler_Range_Ops.union_ranges uu___3 r)
                      bs1 p1.FStar_Syntax_Syntax.pos in
                  let uu___3 =
                    aux bs1 vs1 []
                      {
                        FStar_Syntax_Syntax.n =
                          (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.n);
                        FStar_Syntax_Syntax.pos = range;
                        FStar_Syntax_Syntax.vars =
                          (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.vars);
                        FStar_Syntax_Syntax.hash_code =
                          (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.hash_code)
                      } in
                  (uu___3, noaqs))
         | FStar_Parser_AST.ElimExists (binders, p, q, binder, e) ->
             let uu___2 = desugar_binders env binders in
             (match uu___2 with
              | (env', bs) ->
                  let p1 = desugar_term env' p in
                  let q1 = desugar_term env q in
                  let sq_q =
                    FStar_Syntax_Util.mk_squash FStar_Syntax_Syntax.U_unknown
                      q1 in
                  let uu___3 = desugar_binders env' [binder] in
                  (match uu___3 with
                   | (env'', b_pf_p::[]) ->
                       let e1 = desugar_term env'' e in
                       let rec mk_exists bs1 p2 =
                         match bs1 with
                         | [] -> FStar_Compiler_Effect.failwith "Impossible"
                         | b::[] ->
                             let x = b.FStar_Syntax_Syntax.binder_bv in
                             let head =
                               let uu___4 =
                                 FStar_Syntax_Syntax.lid_and_dd_as_fv
                                   FStar_Parser_Const.exists_lid
                                   FStar_Pervasives_Native.None in
                               FStar_Syntax_Syntax.fv_to_tm uu___4 in
                             let args =
                               let uu___4 =
                                 let uu___5 =
                                   FStar_Syntax_Syntax.as_aqual_implicit true in
                                 ((x.FStar_Syntax_Syntax.sort), uu___5) in
                               let uu___5 =
                                 let uu___6 =
                                   let uu___7 =
                                     let uu___8 =
                                       let uu___9 =
                                         FStar_Compiler_List.hd bs1 in
                                       [uu___9] in
                                     FStar_Syntax_Util.abs uu___8 p2
                                       FStar_Pervasives_Native.None in
                                   (uu___7, FStar_Pervasives_Native.None) in
                                 [uu___6] in
                               uu___4 :: uu___5 in
                             FStar_Syntax_Syntax.mk_Tm_app head args
                               p2.FStar_Syntax_Syntax.pos
                         | b::bs2 ->
                             let body = mk_exists bs2 p2 in
                             mk_exists [b] body in
                       let mk_exists_elim t x_p s_ex_p f r =
                         let head =
                           let uu___4 =
                             FStar_Syntax_Syntax.lid_and_dd_as_fv
                               FStar_Parser_Const.exists_elim_lid
                               FStar_Pervasives_Native.None in
                           FStar_Syntax_Syntax.fv_to_tm uu___4 in
                         let args =
                           let uu___4 =
                             let uu___5 =
                               FStar_Syntax_Syntax.as_aqual_implicit true in
                             (t, uu___5) in
                           let uu___5 =
                             let uu___6 =
                               let uu___7 =
                                 FStar_Syntax_Syntax.as_aqual_implicit true in
                               (x_p, uu___7) in
                             [uu___6;
                             (s_ex_p, FStar_Pervasives_Native.None);
                             (f, FStar_Pervasives_Native.None)] in
                           uu___4 :: uu___5 in
                         FStar_Syntax_Syntax.mk_Tm_app head args r in
                       let rec aux binders1 squash_token =
                         match binders1 with
                         | [] ->
                             FStar_Errors.raise_error
                               FStar_Parser_AST.hasRange_term top
                               FStar_Errors_Codes.Fatal_UnexpectedTerm ()
                               (Obj.magic
                                  FStar_Errors_Msg.is_error_message_string)
                               (Obj.magic "Empty binders in ELIM_EXISTS")
                         | b::[] ->
                             let x = unqual_bv_of_binder b in
                             let uu___4 =
                               FStar_Syntax_Util.abs [b] p1
                                 FStar_Pervasives_Native.None in
                             let uu___5 =
                               let uu___6 =
                                 FStar_Syntax_Util.ascribe e1
                                   ((FStar_Pervasives.Inl sq_q),
                                     FStar_Pervasives_Native.None, false) in
                               FStar_Syntax_Util.abs [b; b_pf_p] uu___6
                                 FStar_Pervasives_Native.None in
                             mk_exists_elim x.FStar_Syntax_Syntax.sort uu___4
                               squash_token uu___5
                               squash_token.FStar_Syntax_Syntax.pos
                         | b::bs1 ->
                             let pf_i =
                               let uu___4 =
                                 let uu___5 =
                                   FStar_Syntax_Syntax.range_of_bv
                                     b.FStar_Syntax_Syntax.binder_bv in
                                 FStar_Pervasives_Native.Some uu___5 in
                               FStar_Syntax_Syntax.gen_bv "pf" uu___4
                                 FStar_Syntax_Syntax.tun in
                             let k =
                               let uu___4 =
                                 FStar_Syntax_Syntax.bv_to_name pf_i in
                               aux bs1 uu___4 in
                             let x = unqual_bv_of_binder b in
                             let uu___4 =
                               let uu___5 = mk_exists bs1 p1 in
                               FStar_Syntax_Util.abs [b] uu___5
                                 FStar_Pervasives_Native.None in
                             let uu___5 =
                               let uu___6 =
                                 let uu___7 =
                                   let uu___8 =
                                     FStar_Syntax_Syntax.mk_binder pf_i in
                                   [uu___8] in
                                 b :: uu___7 in
                               FStar_Syntax_Util.abs uu___6 k
                                 FStar_Pervasives_Native.None in
                             mk_exists_elim x.FStar_Syntax_Syntax.sort uu___4
                               squash_token uu___5
                               squash_token.FStar_Syntax_Syntax.pos in
                       let range =
                         FStar_Compiler_List.fold_right
                           (fun bs1 ->
                              fun r ->
                                let uu___4 =
                                  FStar_Syntax_Syntax.range_of_bv
                                    bs1.FStar_Syntax_Syntax.binder_bv in
                                FStar_Compiler_Range_Ops.union_ranges uu___4
                                  r) bs p1.FStar_Syntax_Syntax.pos in
                       let uu___4 =
                         aux bs
                           {
                             FStar_Syntax_Syntax.n =
                               (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.n);
                             FStar_Syntax_Syntax.pos = range;
                             FStar_Syntax_Syntax.vars =
                               (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.vars);
                             FStar_Syntax_Syntax.hash_code =
                               (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.hash_code)
                           } in
                       (uu___4, noaqs)))
         | FStar_Parser_AST.ElimImplies (p, q, e) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let e1 = desugar_term env e in
             let head =
               let uu___2 =
                 FStar_Syntax_Syntax.lid_and_dd_as_fv
                   FStar_Parser_Const.implies_elim_lid
                   FStar_Pervasives_Native.None in
               FStar_Syntax_Syntax.fv_to_tm uu___2 in
             let args =
               let uu___2 =
                 let uu___3 =
                   let uu___4 =
                     let uu___5 =
                       let uu___6 =
                         FStar_Compiler_Range_Ops.union_ranges
                           p1.FStar_Syntax_Syntax.pos
                           q1.FStar_Syntax_Syntax.pos in
                       {
                         FStar_Syntax_Syntax.n =
                           (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.n);
                         FStar_Syntax_Syntax.pos = uu___6;
                         FStar_Syntax_Syntax.vars =
                           (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.vars);
                         FStar_Syntax_Syntax.hash_code =
                           (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.hash_code)
                       } in
                     (uu___5, FStar_Pervasives_Native.None) in
                   let uu___5 =
                     let uu___6 =
                       let uu___7 = mk_thunk e1 in
                       (uu___7, FStar_Pervasives_Native.None) in
                     [uu___6] in
                   uu___4 :: uu___5 in
                 (q1, FStar_Pervasives_Native.None) :: uu___3 in
               (p1, FStar_Pervasives_Native.None) :: uu___2 in
             let uu___2 =
               FStar_Syntax_Syntax.mk_Tm_app head args
                 top.FStar_Parser_AST.range in
             (uu___2, noaqs)
         | FStar_Parser_AST.ElimOr (p, q, r, x, e1, y, e2) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let r1 = desugar_term env r in
             let uu___2 = desugar_binders env [x] in
             (match uu___2 with
              | (env_x, x1::[]) ->
                  let e11 = desugar_term env_x e1 in
                  let uu___3 = desugar_binders env [y] in
                  (match uu___3 with
                   | (env_y, y1::[]) ->
                       let e21 = desugar_term env_y e2 in
                       let head =
                         let uu___4 =
                           FStar_Syntax_Syntax.lid_and_dd_as_fv
                             FStar_Parser_Const.or_elim_lid
                             FStar_Pervasives_Native.None in
                         FStar_Syntax_Syntax.fv_to_tm uu___4 in
                       let extra_binder =
                         let uu___4 =
                           FStar_Syntax_Syntax.new_bv
                             FStar_Pervasives_Native.None
                             FStar_Syntax_Syntax.tun in
                         FStar_Syntax_Syntax.mk_binder uu___4 in
                       let args =
                         let uu___4 =
                           let uu___5 =
                             let uu___6 = mk_thunk q1 in
                             (uu___6, FStar_Pervasives_Native.None) in
                           let uu___6 =
                             let uu___7 =
                               let uu___8 =
                                 let uu___9 =
                                   let uu___10 =
                                     FStar_Compiler_Range_Ops.union_ranges
                                       p1.FStar_Syntax_Syntax.pos
                                       q1.FStar_Syntax_Syntax.pos in
                                   {
                                     FStar_Syntax_Syntax.n =
                                       (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.n);
                                     FStar_Syntax_Syntax.pos = uu___10;
                                     FStar_Syntax_Syntax.vars =
                                       (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.vars);
                                     FStar_Syntax_Syntax.hash_code =
                                       (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.hash_code)
                                   } in
                                 (uu___9, FStar_Pervasives_Native.None) in
                               let uu___9 =
                                 let uu___10 =
                                   let uu___11 =
                                     FStar_Syntax_Util.abs [x1] e11
                                       FStar_Pervasives_Native.None in
                                   (uu___11, FStar_Pervasives_Native.None) in
                                 let uu___11 =
                                   let uu___12 =
                                     let uu___13 =
                                       FStar_Syntax_Util.abs
                                         [extra_binder; y1] e21
                                         FStar_Pervasives_Native.None in
                                     (uu___13, FStar_Pervasives_Native.None) in
                                   [uu___12] in
                                 uu___10 :: uu___11 in
                               uu___8 :: uu___9 in
                             (r1, FStar_Pervasives_Native.None) :: uu___7 in
                           uu___5 :: uu___6 in
                         (p1, FStar_Pervasives_Native.None) :: uu___4 in
                       let uu___4 =
                         FStar_Syntax_Syntax.mk_Tm_app head args
                           top.FStar_Parser_AST.range in
                       (uu___4, noaqs)))
         | FStar_Parser_AST.ElimAnd (p, q, r, x, y, e) ->
             let p1 = desugar_term env p in
             let q1 = desugar_term env q in
             let r1 = desugar_term env r in
             let uu___2 = desugar_binders env [x; y] in
             (match uu___2 with
              | (env', x1::y1::[]) ->
                  let e1 = desugar_term env' e in
                  let head =
                    let uu___3 =
                      FStar_Syntax_Syntax.lid_and_dd_as_fv
                        FStar_Parser_Const.and_elim_lid
                        FStar_Pervasives_Native.None in
                    FStar_Syntax_Syntax.fv_to_tm uu___3 in
                  let args =
                    let uu___3 =
                      let uu___4 =
                        let uu___5 = mk_thunk q1 in
                        (uu___5, FStar_Pervasives_Native.None) in
                      let uu___5 =
                        let uu___6 =
                          let uu___7 =
                            let uu___8 =
                              let uu___9 =
                                FStar_Compiler_Range_Ops.union_ranges
                                  p1.FStar_Syntax_Syntax.pos
                                  q1.FStar_Syntax_Syntax.pos in
                              {
                                FStar_Syntax_Syntax.n =
                                  (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.n);
                                FStar_Syntax_Syntax.pos = uu___9;
                                FStar_Syntax_Syntax.vars =
                                  (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.vars);
                                FStar_Syntax_Syntax.hash_code =
                                  (FStar_Syntax_Util.exp_unit.FStar_Syntax_Syntax.hash_code)
                              } in
                            (uu___8, FStar_Pervasives_Native.None) in
                          let uu___8 =
                            let uu___9 =
                              let uu___10 =
                                FStar_Syntax_Util.abs [x1; y1] e1
                                  FStar_Pervasives_Native.None in
                              (uu___10, FStar_Pervasives_Native.None) in
                            [uu___9] in
                          uu___7 :: uu___8 in
                        (r1, FStar_Pervasives_Native.None) :: uu___6 in
                      uu___4 :: uu___5 in
                    (p1, FStar_Pervasives_Native.None) :: uu___3 in
                  let uu___3 =
                    FStar_Syntax_Syntax.mk_Tm_app head args
                      top.FStar_Parser_AST.range in
                  (uu___3, noaqs))
         | FStar_Parser_AST.ListLiteral ts ->
             let nil r =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Construct (FStar_Parser_Const.nil_lid, []))
                 r FStar_Parser_AST.Expr in
             let cons r hd tl =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Construct
                    (FStar_Parser_Const.cons_lid,
                      [(hd, FStar_Parser_AST.Nothing);
                      (tl, FStar_Parser_AST.Nothing)])) r
                 FStar_Parser_AST.Expr in
             let t' =
               let uu___2 = nil top.FStar_Parser_AST.range in
               FStar_Compiler_List.fold_right
                 (cons top.FStar_Parser_AST.range) ts uu___2 in
             desugar_term_aq env t'
         | FStar_Parser_AST.SeqLiteral ts ->
             let nil r =
               FStar_Parser_AST.mk_term
                 (FStar_Parser_AST.Var FStar_Parser_Const.seq_empty_lid) r
                 FStar_Parser_AST.Expr in
             let cons r hd tl =
               let uu___2 =
                 FStar_Parser_AST.mk_term
                   (FStar_Parser_AST.Var FStar_Parser_Const.seq_cons_lid) r
                   FStar_Parser_AST.Expr in
               FStar_Parser_AST.mkApp uu___2
                 [(hd, FStar_Parser_AST.Nothing);
                 (tl, FStar_Parser_AST.Nothing)] r in
             let t' =
               let uu___2 = nil top.FStar_Parser_AST.range in
               FStar_Compiler_List.fold_right
                 (cons top.FStar_Parser_AST.range) ts uu___2 in
             desugar_term_aq env t'
         | uu___2 when top.FStar_Parser_AST.level = FStar_Parser_AST.Formula
             -> let uu___3 = desugar_formula env top in (uu___3, noaqs)
         | uu___2 ->
             let uu___3 =
               let uu___4 = FStar_Parser_AST.term_to_string top in
               Prims.strcat "Unexpected term: " uu___4 in
             FStar_Errors.raise_error FStar_Parser_AST.hasRange_term top
               FStar_Errors_Codes.Fatal_UnexpectedTerm ()
               (Obj.magic FStar_Errors_Msg.is_error_message_string)
               (Obj.magic uu___3))
and (desugar_match_returns :
  env_t ->
    FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
      (FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Parser_AST.term * Prims.bool) FStar_Pervasives_Native.option ->
        ((FStar_Syntax_Syntax.binder *
          ((FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax,
          FStar_Syntax_Syntax.comp' FStar_Syntax_Syntax.syntax)
          FStar_Pervasives.either * FStar_Syntax_Syntax.term'
          FStar_Syntax_Syntax.syntax FStar_Pervasives_Native.option *
          Prims.bool)) FStar_Pervasives_Native.option *
          (FStar_Syntax_Syntax.bv * FStar_Syntax_Syntax.term) Prims.list))
  =
  fun env ->
    fun scrutinee ->
      fun asc_opt ->
        match asc_opt with
        | FStar_Pervasives_Native.None -> (FStar_Pervasives_Native.None, [])
        | FStar_Pervasives_Native.Some asc ->
            let uu___ = asc in
            (match uu___ with
             | (asc_b, asc_tc, asc_use_eq) ->
                 let uu___1 =
                   match asc_b with
                   | FStar_Pervasives_Native.None ->
                       let bv =
                         FStar_Syntax_Syntax.gen_bv
                           FStar_Parser_Const.match_returns_def_name
                           (FStar_Pervasives_Native.Some
                              (scrutinee.FStar_Syntax_Syntax.pos))
                           FStar_Syntax_Syntax.tun in
                       let uu___2 = FStar_Syntax_Syntax.mk_binder bv in
                       (env, uu___2)
                   | FStar_Pervasives_Native.Some b ->
                       let uu___2 = FStar_Syntax_DsEnv.push_bv env b in
                       (match uu___2 with
                        | (env1, bv) ->
                            let uu___3 = FStar_Syntax_Syntax.mk_binder bv in
                            (env1, uu___3)) in
                 (match uu___1 with
                  | (env_asc, b) ->
                      let uu___2 =
                        desugar_ascription env_asc asc_tc
                          FStar_Pervasives_Native.None asc_use_eq in
                      (match uu___2 with
                       | (asc1, aq) ->
                           let asc2 =
                             let uu___3 =
                               let uu___4 =
                                 FStar_Syntax_Util.unascribe scrutinee in
                               uu___4.FStar_Syntax_Syntax.n in
                             match uu___3 with
                             | FStar_Syntax_Syntax.Tm_name sbv ->
                                 let uu___4 =
                                   let uu___5 =
                                     let uu___6 =
                                       let uu___7 =
                                         FStar_Syntax_Syntax.bv_to_name
                                           b.FStar_Syntax_Syntax.binder_bv in
                                       (sbv, uu___7) in
                                     FStar_Syntax_Syntax.NT uu___6 in
                                   [uu___5] in
                                 FStar_Syntax_Subst.subst_ascription uu___4
                                   asc1
                             | uu___4 -> asc1 in
                           let asc3 =
                             FStar_Syntax_Subst.close_ascription [b] asc2 in
                           let b1 =
                             let uu___3 =
                               FStar_Syntax_Subst.close_binders [b] in
                             FStar_Compiler_List.hd uu___3 in
                           ((FStar_Pervasives_Native.Some (b1, asc3)), aq))))
and (desugar_ascription :
  env_t ->
    FStar_Parser_AST.term ->
      FStar_Parser_AST.term FStar_Pervasives_Native.option ->
        Prims.bool -> (FStar_Syntax_Syntax.ascription * antiquotations_temp))
  =
  fun env ->
    fun t ->
      fun tac_opt ->
        fun use_eq ->
          let uu___ =
            let uu___1 = is_comp_type env t in
            if uu___1
            then
              (if use_eq
               then
                 FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t
                   FStar_Errors_Codes.Fatal_NotSupported ()
                   (Obj.magic FStar_Errors_Msg.is_error_message_string)
                   (Obj.magic
                      "Equality ascription with computation types is not supported yet")
               else
                 (let comp = desugar_comp t.FStar_Parser_AST.range true env t in
                  ((FStar_Pervasives.Inr comp), [])))
            else
              (let uu___3 = desugar_term_aq env t in
               match uu___3 with
               | (tm, aq) -> ((FStar_Pervasives.Inl tm), aq)) in
          match uu___ with
          | (annot, aq0) ->
              let uu___1 =
                let uu___2 =
                  FStar_Compiler_Util.map_opt tac_opt (desugar_term env) in
                (annot, uu___2, use_eq) in
              (uu___1, aq0)
and (desugar_args :
  FStar_Syntax_DsEnv.env ->
    (FStar_Parser_AST.term * FStar_Parser_AST.imp) Prims.list ->
      (FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.arg_qualifier
        FStar_Pervasives_Native.option) Prims.list)
  =
  fun env ->
    fun args ->
      FStar_Compiler_List.map
        (fun uu___ ->
           match uu___ with
           | (a, imp) ->
               let uu___1 = desugar_term env a in arg_withimp_t imp uu___1)
        args
and (desugar_comp :
  FStar_Compiler_Range_Type.range ->
    Prims.bool ->
      FStar_Syntax_DsEnv.env ->
        FStar_Parser_AST.term -> FStar_Syntax_Syntax.comp)
  =
  fun r ->
    fun allow_type_promotion ->
      fun env ->
        fun t ->
          let fail code msg =
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              code () (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic msg) in
          let is_requires uu___ =
            match uu___ with
            | (t1, uu___1) ->
                let uu___2 =
                  let uu___3 = unparen t1 in uu___3.FStar_Parser_AST.tm in
                (match uu___2 with
                 | FStar_Parser_AST.Requires uu___3 -> true
                 | uu___3 -> false) in
          let is_ensures uu___ =
            match uu___ with
            | (t1, uu___1) ->
                let uu___2 =
                  let uu___3 = unparen t1 in uu___3.FStar_Parser_AST.tm in
                (match uu___2 with
                 | FStar_Parser_AST.Ensures uu___3 -> true
                 | uu___3 -> false) in
          let is_decreases uu___ =
            match uu___ with
            | (t1, uu___1) ->
                let uu___2 =
                  let uu___3 = unparen t1 in uu___3.FStar_Parser_AST.tm in
                (match uu___2 with
                 | FStar_Parser_AST.Decreases uu___3 -> true
                 | uu___3 -> false) in
          let is_smt_pat1 t1 =
            let uu___ = let uu___1 = unparen t1 in uu___1.FStar_Parser_AST.tm in
            match uu___ with
            | FStar_Parser_AST.Construct (smtpat, uu___1) ->
                FStar_Compiler_Util.for_some
                  (fun s ->
                     let uu___2 = FStar_Ident.string_of_lid smtpat in
                     uu___2 = s) ["SMTPat"; "SMTPatT"; "SMTPatOr"]
            | FStar_Parser_AST.Var smtpat ->
                FStar_Compiler_Util.for_some
                  (fun s ->
                     let uu___1 = FStar_Ident.string_of_lid smtpat in
                     uu___1 = s) ["smt_pat"; "smt_pat_or"]
            | uu___1 -> false in
          let is_smt_pat uu___ =
            match uu___ with
            | (t1, uu___1) ->
                let uu___2 =
                  let uu___3 = unparen t1 in uu___3.FStar_Parser_AST.tm in
                (match uu___2 with
                 | FStar_Parser_AST.ListLiteral ts ->
                     FStar_Compiler_Util.for_all is_smt_pat1 ts
                 | uu___3 -> false) in
          let pre_process_comp_typ t1 =
            let uu___ = head_and_args t1 in
            match uu___ with
            | (head, args) ->
                (match head.FStar_Parser_AST.tm with
                 | FStar_Parser_AST.Name lemma when
                     let uu___1 =
                       let uu___2 = FStar_Ident.ident_of_lid lemma in
                       FStar_Ident.string_of_id uu___2 in
                     uu___1 = "Lemma" ->
                     let unit_tm =
                       let uu___1 =
                         FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Name FStar_Parser_Const.unit_lid)
                           t1.FStar_Parser_AST.range
                           FStar_Parser_AST.Type_level in
                       (uu___1, FStar_Parser_AST.Nothing) in
                     let nil_pat =
                       let uu___1 =
                         FStar_Parser_AST.mk_term
                           (FStar_Parser_AST.Name FStar_Parser_Const.nil_lid)
                           t1.FStar_Parser_AST.range FStar_Parser_AST.Expr in
                       (uu___1, FStar_Parser_AST.Nothing) in
                     let req_true =
                       let req =
                         let uu___1 =
                           let uu___2 =
                             FStar_Parser_AST.mk_term
                               (FStar_Parser_AST.Name
                                  FStar_Parser_Const.true_lid)
                               t1.FStar_Parser_AST.range
                               FStar_Parser_AST.Formula in
                           (uu___2, FStar_Pervasives_Native.None) in
                         FStar_Parser_AST.Requires uu___1 in
                       let uu___1 =
                         FStar_Parser_AST.mk_term req
                           t1.FStar_Parser_AST.range
                           FStar_Parser_AST.Type_level in
                       (uu___1, FStar_Parser_AST.Nothing) in
                     let thunk_ens uu___1 =
                       match uu___1 with
                       | (e, i) ->
                           let uu___2 = FStar_Parser_AST.thunk e in
                           (uu___2, i) in
                     let fail_lemma uu___1 =
                       let expected_one_of =
                         ["Lemma post";
                         "Lemma (ensures post)";
                         "Lemma (requires pre) (ensures post)";
                         "Lemma post [SMTPat ...]";
                         "Lemma (ensures post) [SMTPat ...]";
                         "Lemma (ensures post) (decreases d)";
                         "Lemma (ensures post) (decreases d) [SMTPat ...]";
                         "Lemma (requires pre) (ensures post) (decreases d)";
                         "Lemma (requires pre) (ensures post) [SMTPat ...]";
                         "Lemma (requires pre) (ensures post) (decreases d) [SMTPat ...]"] in
                       let uu___2 =
                         let uu___3 =
                           let uu___4 =
                             FStar_Errors_Msg.text
                               "Invalid arguments to 'Lemma'; expected one of the following" in
                           let uu___5 =
                             let uu___6 =
                               FStar_Compiler_List.map
                                 FStar_Pprint.doc_of_string expected_one_of in
                             FStar_Errors_Msg.sublist FStar_Pprint.empty
                               uu___6 in
                           FStar_Pprint.op_Hat_Hat uu___4 uu___5 in
                         [uu___3] in
                       FStar_Errors.raise_error
                         FStar_Parser_AST.hasRange_term t1
                         FStar_Errors_Codes.Fatal_InvalidLemmaArgument ()
                         (Obj.magic
                            FStar_Errors_Msg.is_error_message_list_doc)
                         (Obj.magic uu___2) in
                     let args1 =
                       match args with
                       | [] -> fail_lemma ()
                       | req::[] when is_requires req -> fail_lemma ()
                       | smtpat::[] when is_smt_pat smtpat -> fail_lemma ()
                       | dec::[] when is_decreases dec -> fail_lemma ()
                       | ens::[] ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; nil_pat] in
                             req_true :: uu___2 in
                           unit_tm :: uu___1
                       | req::ens::[] when
                           (is_requires req) && (is_ensures ens) ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; nil_pat] in
                             req :: uu___2 in
                           unit_tm :: uu___1
                       | ens::smtpat::[] when
                           (((let uu___1 = is_requires ens in
                              Prims.op_Negation uu___1) &&
                               (let uu___1 = is_smt_pat ens in
                                Prims.op_Negation uu___1))
                              &&
                              (let uu___1 = is_decreases ens in
                               Prims.op_Negation uu___1))
                             && (is_smt_pat smtpat)
                           ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in [uu___3; smtpat] in
                             req_true :: uu___2 in
                           unit_tm :: uu___1
                       | ens::dec::[] when
                           (is_ensures ens) && (is_decreases dec) ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; nil_pat; dec] in
                             req_true :: uu___2 in
                           unit_tm :: uu___1
                       | ens::dec::smtpat::[] when
                           ((is_ensures ens) && (is_decreases dec)) &&
                             (is_smt_pat smtpat)
                           ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; smtpat; dec] in
                             req_true :: uu___2 in
                           unit_tm :: uu___1
                       | req::ens::dec::[] when
                           ((is_requires req) && (is_ensures ens)) &&
                             (is_decreases dec)
                           ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; nil_pat; dec] in
                             req :: uu___2 in
                           unit_tm :: uu___1
                       | req::ens::smtpat::[] when
                           ((is_requires req) && (is_ensures ens)) &&
                             (is_smt_pat smtpat)
                           ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in [uu___3; smtpat] in
                             req :: uu___2 in
                           unit_tm :: uu___1
                       | req::ens::dec::smtpat::[] when
                           (((is_requires req) && (is_ensures ens)) &&
                              (is_smt_pat smtpat))
                             && (is_decreases dec)
                           ->
                           let uu___1 =
                             let uu___2 =
                               let uu___3 = thunk_ens ens in
                               [uu___3; dec; smtpat] in
                             req :: uu___2 in
                           unit_tm :: uu___1
                       | _other -> fail_lemma () in
                     let head_and_attributes =
                       FStar_Syntax_DsEnv.fail_or env
                         (FStar_Syntax_DsEnv.try_lookup_effect_name_and_attributes
                            env) lemma in
                     (head_and_attributes, args1)
                 | FStar_Parser_AST.Name l when
                     FStar_Syntax_DsEnv.is_effect_name env l ->
                     let uu___1 =
                       FStar_Syntax_DsEnv.fail_or env
                         (FStar_Syntax_DsEnv.try_lookup_effect_name_and_attributes
                            env) l in
                     (uu___1, args)
                 | FStar_Parser_AST.Name l when
                     (let uu___1 = FStar_Syntax_DsEnv.current_module env in
                      FStar_Ident.lid_equals uu___1
                        FStar_Parser_Const.prims_lid)
                       &&
                       (let uu___1 =
                          let uu___2 = FStar_Ident.ident_of_lid l in
                          FStar_Ident.string_of_id uu___2 in
                        uu___1 = "Tot")
                     ->
                     let uu___1 =
                       let uu___2 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_Tot_lid
                           head.FStar_Parser_AST.range in
                       (uu___2, []) in
                     (uu___1, args)
                 | FStar_Parser_AST.Name l when
                     (let uu___1 = FStar_Syntax_DsEnv.current_module env in
                      FStar_Ident.lid_equals uu___1
                        FStar_Parser_Const.prims_lid)
                       &&
                       (let uu___1 =
                          let uu___2 = FStar_Ident.ident_of_lid l in
                          FStar_Ident.string_of_id uu___2 in
                        uu___1 = "GTot")
                     ->
                     let uu___1 =
                       let uu___2 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_GTot_lid
                           head.FStar_Parser_AST.range in
                       (uu___2, []) in
                     (uu___1, args)
                 | FStar_Parser_AST.Name l when
                     ((let uu___1 =
                         let uu___2 = FStar_Ident.ident_of_lid l in
                         FStar_Ident.string_of_id uu___2 in
                       uu___1 = "Type") ||
                        (let uu___1 =
                           let uu___2 = FStar_Ident.ident_of_lid l in
                           FStar_Ident.string_of_id uu___2 in
                         uu___1 = "Type0"))
                       ||
                       (let uu___1 =
                          let uu___2 = FStar_Ident.ident_of_lid l in
                          FStar_Ident.string_of_id uu___2 in
                        uu___1 = "Effect")
                     ->
                     let uu___1 =
                       let uu___2 =
                         FStar_Ident.set_lid_range
                           FStar_Parser_Const.effect_Tot_lid
                           head.FStar_Parser_AST.range in
                       (uu___2, []) in
                     (uu___1, [(t1, FStar_Parser_AST.Nothing)])
                 | uu___1 when allow_type_promotion ->
                     let default_effect =
                       let uu___2 = FStar_Options.ml_ish () in
                       if uu___2
                       then FStar_Parser_Const.effect_ML_lid ()
                       else
                         ((let uu___5 = FStar_Options.warn_default_effects () in
                           if uu___5
                           then
                             FStar_Errors.log_issue
                               FStar_Parser_AST.hasRange_term head
                               FStar_Errors_Codes.Warning_UseDefaultEffect ()
                               (Obj.magic
                                  FStar_Errors_Msg.is_error_message_string)
                               (Obj.magic "Using default effect Tot")
                           else ());
                          FStar_Parser_Const.effect_Tot_lid) in
                     let uu___2 =
                       let uu___3 =
                         FStar_Ident.set_lid_range default_effect
                           head.FStar_Parser_AST.range in
                       (uu___3, []) in
                     (uu___2, [(t1, FStar_Parser_AST.Nothing)])
                 | uu___1 ->
                     FStar_Errors.raise_error FStar_Parser_AST.hasRange_term
                       t1 FStar_Errors_Codes.Fatal_EffectNotFound ()
                       (Obj.magic FStar_Errors_Msg.is_error_message_string)
                       (Obj.magic "Expected an effect constructor")) in
          let uu___ = pre_process_comp_typ t in
          match uu___ with
          | ((eff, cattributes), args) ->
              (if (FStar_Compiler_List.length args) = Prims.int_zero
               then
                 (let uu___2 =
                    let uu___3 =
                      FStar_Class_Show.show FStar_Ident.showable_lident eff in
                    FStar_Compiler_Util.format1
                      "Not enough args to effect %s" uu___3 in
                  fail FStar_Errors_Codes.Fatal_NotEnoughArgsToEffect uu___2)
               else ();
               (let is_universe uu___2 =
                  match uu___2 with
                  | (uu___3, imp) -> imp = FStar_Parser_AST.UnivApp in
                let uu___2 = FStar_Compiler_Util.take is_universe args in
                match uu___2 with
                | (universes, args1) ->
                    let universes1 =
                      FStar_Compiler_List.map
                        (fun uu___3 ->
                           match uu___3 with | (u, imp) -> desugar_universe u)
                        universes in
                    let uu___3 =
                      let uu___4 = FStar_Compiler_List.hd args1 in
                      let uu___5 = FStar_Compiler_List.tl args1 in
                      (uu___4, uu___5) in
                    (match uu___3 with
                     | (result_arg, rest) ->
                         let result_typ =
                           desugar_typ env
                             (FStar_Pervasives_Native.fst result_arg) in
                         let uu___4 =
                           let is_decrease t1 =
                             let uu___5 =
                               let uu___6 =
                                 unparen (FStar_Pervasives_Native.fst t1) in
                               uu___6.FStar_Parser_AST.tm in
                             match uu___5 with
                             | FStar_Parser_AST.Decreases uu___6 -> true
                             | uu___6 -> false in
                           FStar_Compiler_List.partition is_decrease rest in
                         (match uu___4 with
                          | (dec, rest1) ->
                              let rest2 = desugar_args env rest1 in
                              let decreases_clause =
                                FStar_Compiler_List.map
                                  (fun t1 ->
                                     let uu___5 =
                                       let uu___6 =
                                         unparen
                                           (FStar_Pervasives_Native.fst t1) in
                                       uu___6.FStar_Parser_AST.tm in
                                     match uu___5 with
                                     | FStar_Parser_AST.Decreases
                                         (t2, uu___6) ->
                                         let dec_order =
                                           let t3 = unparen t2 in
                                           match t3.FStar_Parser_AST.tm with
                                           | FStar_Parser_AST.LexList l ->
                                               let uu___7 =
                                                 FStar_Compiler_List.map
                                                   (desugar_term env) l in
                                               FStar_Syntax_Syntax.Decreases_lex
                                                 uu___7
                                           | FStar_Parser_AST.WFOrder
                                               (t11, t21) ->
                                               let uu___7 =
                                                 let uu___8 =
                                                   desugar_term env t11 in
                                                 let uu___9 =
                                                   desugar_term env t21 in
                                                 (uu___8, uu___9) in
                                               FStar_Syntax_Syntax.Decreases_wf
                                                 uu___7
                                           | uu___7 ->
                                               let uu___8 =
                                                 let uu___9 =
                                                   desugar_term env t3 in
                                                 [uu___9] in
                                               FStar_Syntax_Syntax.Decreases_lex
                                                 uu___8 in
                                         FStar_Syntax_Syntax.DECREASES
                                           dec_order
                                     | uu___6 ->
                                         fail
                                           FStar_Errors_Codes.Fatal_UnexpectedComputationTypeForLetRec
                                           "Unexpected decreases clause") dec in
                              let no_additional_args =
                                let is_empty l =
                                  match l with | [] -> true | uu___5 -> false in
                                (((is_empty decreases_clause) &&
                                    (is_empty rest2))
                                   && (is_empty cattributes))
                                  && (is_empty universes1) in
                              let uu___5 =
                                no_additional_args &&
                                  (FStar_Ident.lid_equals eff
                                     FStar_Parser_Const.effect_Tot_lid) in
                              if uu___5
                              then FStar_Syntax_Syntax.mk_Total result_typ
                              else
                                (let uu___7 =
                                   no_additional_args &&
                                     (FStar_Ident.lid_equals eff
                                        FStar_Parser_Const.effect_GTot_lid) in
                                 if uu___7
                                 then
                                   FStar_Syntax_Syntax.mk_GTotal result_typ
                                 else
                                   (let flags =
                                      let uu___9 =
                                        FStar_Ident.lid_equals eff
                                          FStar_Parser_Const.effect_Lemma_lid in
                                      if uu___9
                                      then [FStar_Syntax_Syntax.LEMMA]
                                      else
                                        (let uu___11 =
                                           FStar_Ident.lid_equals eff
                                             FStar_Parser_Const.effect_Tot_lid in
                                         if uu___11
                                         then [FStar_Syntax_Syntax.TOTAL]
                                         else
                                           (let uu___13 =
                                              let uu___14 =
                                                FStar_Parser_Const.effect_ML_lid
                                                  () in
                                              FStar_Ident.lid_equals eff
                                                uu___14 in
                                            if uu___13
                                            then
                                              [FStar_Syntax_Syntax.MLEFFECT]
                                            else
                                              (let uu___15 =
                                                 FStar_Ident.lid_equals eff
                                                   FStar_Parser_Const.effect_GTot_lid in
                                               if uu___15
                                               then
                                                 [FStar_Syntax_Syntax.SOMETRIVIAL]
                                               else []))) in
                                    let flags1 =
                                      FStar_Compiler_List.op_At flags
                                        cattributes in
                                    let rest3 =
                                      let uu___9 =
                                        FStar_Ident.lid_equals eff
                                          FStar_Parser_Const.effect_Lemma_lid in
                                      if uu___9
                                      then
                                        match rest2 with
                                        | req::ens::(pat, aq)::[] ->
                                            let pat1 =
                                              match pat.FStar_Syntax_Syntax.n
                                              with
                                              | FStar_Syntax_Syntax.Tm_fvar
                                                  fv when
                                                  FStar_Syntax_Syntax.fv_eq_lid
                                                    fv
                                                    FStar_Parser_Const.nil_lid
                                                  ->
                                                  let nil =
                                                    FStar_Syntax_Syntax.mk_Tm_uinst
                                                      pat
                                                      [FStar_Syntax_Syntax.U_zero] in
                                                  let pattern =
                                                    let uu___10 =
                                                      FStar_Ident.set_lid_range
                                                        FStar_Parser_Const.pattern_lid
                                                        pat.FStar_Syntax_Syntax.pos in
                                                    FStar_Syntax_Syntax.fvar_with_dd
                                                      uu___10
                                                      FStar_Pervasives_Native.None in
                                                  let uu___10 =
                                                    let uu___11 =
                                                      let uu___12 =
                                                        FStar_Syntax_Syntax.as_aqual_implicit
                                                          true in
                                                      (pattern, uu___12) in
                                                    [uu___11] in
                                                  FStar_Syntax_Syntax.mk_Tm_app
                                                    nil uu___10
                                                    pat.FStar_Syntax_Syntax.pos
                                              | uu___10 -> pat in
                                            let uu___10 =
                                              let uu___11 =
                                                let uu___12 =
                                                  let uu___13 =
                                                    FStar_Syntax_Syntax.mk
                                                      (FStar_Syntax_Syntax.Tm_meta
                                                         {
                                                           FStar_Syntax_Syntax.tm2
                                                             = pat1;
                                                           FStar_Syntax_Syntax.meta
                                                             =
                                                             (FStar_Syntax_Syntax.Meta_desugared
                                                                FStar_Syntax_Syntax.Meta_smt_pat)
                                                         })
                                                      pat1.FStar_Syntax_Syntax.pos in
                                                  (uu___13, aq) in
                                                [uu___12] in
                                              ens :: uu___11 in
                                            req :: uu___10
                                        | uu___10 -> rest2
                                      else rest2 in
                                    FStar_Syntax_Syntax.mk_Comp
                                      {
                                        FStar_Syntax_Syntax.comp_univs =
                                          universes1;
                                        FStar_Syntax_Syntax.effect_name = eff;
                                        FStar_Syntax_Syntax.result_typ =
                                          result_typ;
                                        FStar_Syntax_Syntax.effect_args =
                                          rest3;
                                        FStar_Syntax_Syntax.flags =
                                          (FStar_Compiler_List.op_At flags1
                                             decreases_clause)
                                      }))))))
and (desugar_formula :
  FStar_Syntax_DsEnv.env -> FStar_Parser_AST.term -> FStar_Syntax_Syntax.term)
  =
  fun env ->
    fun f ->
      let mk t = FStar_Syntax_Syntax.mk t f.FStar_Parser_AST.range in
      let setpos t =
        {
          FStar_Syntax_Syntax.n = (t.FStar_Syntax_Syntax.n);
          FStar_Syntax_Syntax.pos = (f.FStar_Parser_AST.range);
          FStar_Syntax_Syntax.vars = (t.FStar_Syntax_Syntax.vars);
          FStar_Syntax_Syntax.hash_code = (t.FStar_Syntax_Syntax.hash_code)
        } in
      let desugar_quant q_head b pats should_wrap_with_pat body =
        let tk =
          desugar_binder env
            {
              FStar_Parser_AST.b = (b.FStar_Parser_AST.b);
              FStar_Parser_AST.brange = (b.FStar_Parser_AST.brange);
              FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
              FStar_Parser_AST.aqual = (b.FStar_Parser_AST.aqual);
              FStar_Parser_AST.battributes = (b.FStar_Parser_AST.battributes)
            } in
        let with_pats env1 uu___ body1 =
          match uu___ with
          | (names, pats1) ->
              (match (names, pats1) with
               | ([], []) -> body1
               | ([], uu___1::uu___2) ->
                   FStar_Compiler_Effect.failwith
                     "Impossible: Annotated pattern without binders in scope"
               | uu___1 ->
                   let names1 =
                     FStar_Compiler_List.map
                       (fun i ->
                          let uu___2 =
                            FStar_Syntax_DsEnv.fail_or2
                              (FStar_Syntax_DsEnv.try_lookup_id env1) i in
                          let uu___3 = FStar_Ident.range_of_id i in
                          {
                            FStar_Syntax_Syntax.n =
                              (uu___2.FStar_Syntax_Syntax.n);
                            FStar_Syntax_Syntax.pos = uu___3;
                            FStar_Syntax_Syntax.vars =
                              (uu___2.FStar_Syntax_Syntax.vars);
                            FStar_Syntax_Syntax.hash_code =
                              (uu___2.FStar_Syntax_Syntax.hash_code)
                          }) names in
                   let pats2 =
                     FStar_Compiler_List.map
                       (fun es ->
                          FStar_Compiler_List.map
                            (fun e ->
                               let uu___2 = desugar_term env1 e in
                               arg_withimp_t FStar_Parser_AST.Nothing uu___2)
                            es) pats1 in
                   (match pats2 with
                    | [] when Prims.op_Negation should_wrap_with_pat -> body1
                    | uu___2 ->
                        mk
                          (FStar_Syntax_Syntax.Tm_meta
                             {
                               FStar_Syntax_Syntax.tm2 = body1;
                               FStar_Syntax_Syntax.meta =
                                 (FStar_Syntax_Syntax.Meta_pattern
                                    (names1, pats2))
                             }))) in
        match tk with
        | (FStar_Pervasives_Native.Some a, k, uu___) ->
            let uu___1 = FStar_Syntax_DsEnv.push_bv env a in
            (match uu___1 with
             | (env1, a1) ->
                 let a2 =
                   {
                     FStar_Syntax_Syntax.ppname =
                       (a1.FStar_Syntax_Syntax.ppname);
                     FStar_Syntax_Syntax.index =
                       (a1.FStar_Syntax_Syntax.index);
                     FStar_Syntax_Syntax.sort = k
                   } in
                 let body1 = desugar_formula env1 body in
                 let body2 = with_pats env1 pats body1 in
                 let body3 =
                   let uu___2 =
                     let uu___3 =
                       let uu___4 = FStar_Syntax_Syntax.mk_binder a2 in
                       [uu___4] in
                     no_annot_abs uu___3 body2 in
                   setpos uu___2 in
                 let uu___2 =
                   let uu___3 =
                     let uu___4 =
                       let uu___5 = FStar_Syntax_Syntax.as_arg body3 in
                       [uu___5] in
                     {
                       FStar_Syntax_Syntax.hd = q_head;
                       FStar_Syntax_Syntax.args = uu___4
                     } in
                   FStar_Syntax_Syntax.Tm_app uu___3 in
                 mk uu___2)
        | uu___ -> FStar_Compiler_Effect.failwith "impossible" in
      let push_quant q binders pats body =
        match binders with
        | b::b'::_rest ->
            let rest = b' :: _rest in
            let body1 =
              let uu___ = q (rest, pats, body) in
              let uu___1 =
                FStar_Compiler_Range_Ops.union_ranges
                  b'.FStar_Parser_AST.brange body.FStar_Parser_AST.range in
              FStar_Parser_AST.mk_term uu___ uu___1 FStar_Parser_AST.Formula in
            let uu___ = q ([b], ([], []), body1) in
            FStar_Parser_AST.mk_term uu___ f.FStar_Parser_AST.range
              FStar_Parser_AST.Formula
        | uu___ -> FStar_Compiler_Effect.failwith "impossible" in
      let uu___ = let uu___1 = unparen f in uu___1.FStar_Parser_AST.tm in
      match uu___ with
      | FStar_Parser_AST.Labeled (f1, l, p) ->
          let f2 = desugar_formula env f1 in
          let uu___1 =
            let uu___2 =
              let uu___3 =
                let uu___4 =
                  let uu___5 = FStar_Errors_Msg.mkmsg l in
                  (uu___5, (f2.FStar_Syntax_Syntax.pos), p) in
                FStar_Syntax_Syntax.Meta_labeled uu___4 in
              {
                FStar_Syntax_Syntax.tm2 = f2;
                FStar_Syntax_Syntax.meta = uu___3
              } in
            FStar_Syntax_Syntax.Tm_meta uu___2 in
          mk uu___1
      | FStar_Parser_AST.QForall ([], uu___1, uu___2) ->
          FStar_Compiler_Effect.failwith
            "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QExists ([], uu___1, uu___2) ->
          FStar_Compiler_Effect.failwith
            "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QuantOp (uu___1, [], uu___2, uu___3) ->
          FStar_Compiler_Effect.failwith
            "Impossible: Quantifier without binders"
      | FStar_Parser_AST.QForall (_1::_2::_3, pats, body) ->
          let binders = _1 :: _2 :: _3 in
          let uu___1 =
            push_quant (fun x -> FStar_Parser_AST.QForall x) binders pats
              body in
          desugar_formula env uu___1
      | FStar_Parser_AST.QExists (_1::_2::_3, pats, body) ->
          let binders = _1 :: _2 :: _3 in
          let uu___1 =
            push_quant (fun x -> FStar_Parser_AST.QExists x) binders pats
              body in
          desugar_formula env uu___1
      | FStar_Parser_AST.QuantOp (i, _1::_2::_3, pats, body) ->
          let binders = _1 :: _2 :: _3 in
          let uu___1 =
            push_quant
              (fun uu___2 ->
                 match uu___2 with
                 | (x, y, z) -> FStar_Parser_AST.QuantOp (i, x, y, z))
              binders pats body in
          desugar_formula env uu___1
      | FStar_Parser_AST.QForall (b::[], pats, body) ->
          let q = FStar_Parser_Const.forall_lid in
          let q_head =
            let uu___1 =
              FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange in
            FStar_Syntax_Syntax.fvar_with_dd uu___1
              FStar_Pervasives_Native.None in
          desugar_quant q_head b pats true body
      | FStar_Parser_AST.QExists (b::[], pats, body) ->
          let q = FStar_Parser_Const.exists_lid in
          let q_head =
            let uu___1 =
              FStar_Ident.set_lid_range q b.FStar_Parser_AST.brange in
            FStar_Syntax_Syntax.fvar_with_dd uu___1
              FStar_Pervasives_Native.None in
          desugar_quant q_head b pats true body
      | FStar_Parser_AST.QuantOp (i, b::[], pats, body) ->
          let q_head =
            let uu___1 = op_as_term env Prims.int_zero i in
            match uu___1 with
            | FStar_Pervasives_Native.None ->
                let uu___2 =
                  let uu___3 = FStar_Ident.string_of_id i in
                  FStar_Compiler_Util.format1
                    "quantifier operator %s not found" uu___3 in
                FStar_Errors.raise_error FStar_Ident.hasrange_ident i
                  FStar_Errors_Codes.Fatal_VariableNotFound ()
                  (Obj.magic FStar_Errors_Msg.is_error_message_string)
                  (Obj.magic uu___2)
            | FStar_Pervasives_Native.Some t -> t in
          desugar_quant q_head b pats false body
      | FStar_Parser_AST.Paren f1 ->
          FStar_Compiler_Effect.failwith "impossible"
      | uu___1 -> desugar_term env f
and (desugar_binder_aq :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder ->
      ((FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.attribute Prims.list)
        * antiquotations_temp))
  =
  fun env ->
    fun b ->
      let attrs =
        FStar_Compiler_List.map (desugar_term env)
          b.FStar_Parser_AST.battributes in
      match b.FStar_Parser_AST.b with
      | FStar_Parser_AST.TAnnotated (x, t) ->
          let uu___ = desugar_typ_aq env t in
          (match uu___ with
           | (ty, aqs) ->
               (((FStar_Pervasives_Native.Some x), ty, attrs), aqs))
      | FStar_Parser_AST.Annotated (x, t) ->
          let uu___ = desugar_typ_aq env t in
          (match uu___ with
           | (ty, aqs) ->
               (((FStar_Pervasives_Native.Some x), ty, attrs), aqs))
      | FStar_Parser_AST.NoName t ->
          let uu___ = desugar_typ_aq env t in
          (match uu___ with
           | (ty, aqs) -> ((FStar_Pervasives_Native.None, ty, attrs), aqs))
      | FStar_Parser_AST.TVariable x ->
          let uu___ =
            let uu___1 =
              let uu___2 = FStar_Ident.range_of_id x in
              FStar_Syntax_Syntax.mk
                (FStar_Syntax_Syntax.Tm_type FStar_Syntax_Syntax.U_unknown)
                uu___2 in
            ((FStar_Pervasives_Native.Some x), uu___1, attrs) in
          (uu___, [])
      | FStar_Parser_AST.Variable x ->
          let uu___ =
            let uu___1 =
              let uu___2 = FStar_Ident.range_of_id x in tun_r uu___2 in
            ((FStar_Pervasives_Native.Some x), uu___1, attrs) in
          (uu___, [])
and (desugar_binder :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder ->
      (FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.attribute Prims.list))
  =
  fun env ->
    fun b ->
      let uu___ = desugar_binder_aq env b in
      match uu___ with | (r, aqs) -> (check_no_aq aqs; r)
and (desugar_vquote :
  env_t ->
    FStar_Parser_AST.term -> FStar_Compiler_Range_Type.range -> Prims.string)
  =
  fun env ->
    fun e ->
      fun r ->
        let tm = desugar_term env e in
        let uu___ =
          let uu___1 = FStar_Syntax_Subst.compress tm in
          uu___1.FStar_Syntax_Syntax.n in
        match uu___ with
        | FStar_Syntax_Syntax.Tm_fvar fv ->
            let uu___1 = FStar_Syntax_Syntax.lid_of_fv fv in
            FStar_Ident.string_of_lid uu___1
        | uu___1 ->
            let uu___2 =
              let uu___3 =
                FStar_Class_Show.show FStar_Syntax_Print.showable_term tm in
              Prims.strcat "VQuote, expected an fvar, got: " uu___3 in
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              FStar_Errors_Codes.Fatal_UnexpectedTermVQuote ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic uu___2)
and (as_binder :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.arg_qualifier FStar_Pervasives_Native.option ->
      (FStar_Ident.ident FStar_Pervasives_Native.option *
        FStar_Syntax_Syntax.term * FStar_Syntax_Syntax.attribute Prims.list)
        -> (FStar_Syntax_Syntax.binder * FStar_Syntax_DsEnv.env))
  =
  fun env ->
    fun imp ->
      fun uu___ ->
        match uu___ with
        | (FStar_Pervasives_Native.None, k, attrs) ->
            let uu___1 =
              let uu___2 = FStar_Syntax_Syntax.null_bv k in
              let uu___3 = trans_bqual env imp in
              mk_binder_with_attrs uu___2 uu___3 attrs in
            (uu___1, env)
        | (FStar_Pervasives_Native.Some a, k, attrs) ->
            let uu___1 = FStar_Syntax_DsEnv.push_bv env a in
            (match uu___1 with
             | (env1, a1) ->
                 let uu___2 =
                   let uu___3 = trans_bqual env1 imp in
                   mk_binder_with_attrs
                     {
                       FStar_Syntax_Syntax.ppname =
                         (a1.FStar_Syntax_Syntax.ppname);
                       FStar_Syntax_Syntax.index =
                         (a1.FStar_Syntax_Syntax.index);
                       FStar_Syntax_Syntax.sort = k
                     } uu___3 attrs in
                 (uu___2, env1))
and (trans_bqual :
  env_t ->
    FStar_Parser_AST.arg_qualifier FStar_Pervasives_Native.option ->
      FStar_Syntax_Syntax.bqual)
  =
  fun env ->
    fun uu___ ->
      match uu___ with
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Implicit) ->
          FStar_Pervasives_Native.Some FStar_Syntax_Syntax.imp_tag
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Equality) ->
          FStar_Pervasives_Native.Some FStar_Syntax_Syntax.Equality
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.Meta t) ->
          let uu___1 =
            let uu___2 = desugar_term env t in
            FStar_Syntax_Syntax.Meta uu___2 in
          FStar_Pervasives_Native.Some uu___1
      | FStar_Pervasives_Native.Some (FStar_Parser_AST.TypeClassArg) ->
          let tcresolve =
            let uu___1 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Var FStar_Parser_Const.tcresolve_lid)
                FStar_Compiler_Range_Type.dummyRange FStar_Parser_AST.Expr in
            desugar_term env uu___1 in
          FStar_Pervasives_Native.Some (FStar_Syntax_Syntax.Meta tcresolve)
      | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
let (typars_of_binders :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.binders))
  =
  fun env ->
    fun bs ->
      let uu___ =
        FStar_Compiler_List.fold_left
          (fun uu___1 ->
             fun b ->
               match uu___1 with
               | (env1, out) ->
                   let tk =
                     desugar_binder env1
                       {
                         FStar_Parser_AST.b = (b.FStar_Parser_AST.b);
                         FStar_Parser_AST.brange =
                           (b.FStar_Parser_AST.brange);
                         FStar_Parser_AST.blevel = FStar_Parser_AST.Formula;
                         FStar_Parser_AST.aqual = (b.FStar_Parser_AST.aqual);
                         FStar_Parser_AST.battributes =
                           (b.FStar_Parser_AST.battributes)
                       } in
                   (match tk with
                    | (FStar_Pervasives_Native.Some a, k, attrs) ->
                        let uu___2 = FStar_Syntax_DsEnv.push_bv env1 a in
                        (match uu___2 with
                         | (env2, a1) ->
                             let a2 =
                               {
                                 FStar_Syntax_Syntax.ppname =
                                   (a1.FStar_Syntax_Syntax.ppname);
                                 FStar_Syntax_Syntax.index =
                                   (a1.FStar_Syntax_Syntax.index);
                                 FStar_Syntax_Syntax.sort = k
                               } in
                             let uu___3 =
                               let uu___4 =
                                 let uu___5 =
                                   trans_bqual env2 b.FStar_Parser_AST.aqual in
                                 mk_binder_with_attrs a2 uu___5 attrs in
                               uu___4 :: out in
                             (env2, uu___3))
                    | uu___2 ->
                        FStar_Errors.raise_error
                          FStar_Parser_AST.hasRange_binder b
                          FStar_Errors_Codes.Fatal_UnexpectedBinder ()
                          (Obj.magic FStar_Errors_Msg.is_error_message_string)
                          (Obj.magic "Unexpected binder"))) (env, []) bs in
      match uu___ with
      | (env1, tpars) -> (env1, (FStar_Compiler_List.rev tpars))
let (desugar_attributes :
  env_t ->
    FStar_Parser_AST.term Prims.list -> FStar_Syntax_Syntax.cflag Prims.list)
  =
  fun env ->
    fun cattributes ->
      let desugar_attribute t =
        let uu___ = let uu___1 = unparen t in uu___1.FStar_Parser_AST.tm in
        match uu___ with
        | FStar_Parser_AST.Var lid when
            let uu___1 = FStar_Ident.string_of_lid lid in uu___1 = "cps" ->
            FStar_Syntax_Syntax.CPS
        | uu___1 ->
            let uu___2 =
              let uu___3 = FStar_Parser_AST.term_to_string t in
              Prims.strcat "Unknown attribute " uu___3 in
            FStar_Errors.raise_error FStar_Parser_AST.hasRange_term t
              FStar_Errors_Codes.Fatal_UnknownAttribute ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic uu___2) in
      FStar_Compiler_List.map desugar_attribute cattributes
let (binder_ident :
  FStar_Parser_AST.binder -> FStar_Ident.ident FStar_Pervasives_Native.option)
  =
  fun b ->
    match b.FStar_Parser_AST.b with
    | FStar_Parser_AST.TAnnotated (x, uu___) ->
        FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.Annotated (x, uu___) -> FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.TVariable x -> FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.Variable x -> FStar_Pervasives_Native.Some x
    | FStar_Parser_AST.NoName uu___ -> FStar_Pervasives_Native.None
let (binder_idents :
  FStar_Parser_AST.binder Prims.list -> FStar_Ident.ident Prims.list) =
  fun bs ->
    FStar_Compiler_List.collect
      (fun b ->
         let uu___ = binder_ident b in FStar_Common.list_of_option uu___) bs
let (mk_data_discriminators :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_DsEnv.env ->
      FStar_Ident.lident Prims.list ->
        FStar_Syntax_Syntax.attribute Prims.list ->
          FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun quals ->
    fun env ->
      fun datas ->
        fun attrs ->
          let quals1 =
            FStar_Compiler_List.filter
              (fun uu___ ->
                 match uu___ with
                 | FStar_Syntax_Syntax.NoExtract -> true
                 | FStar_Syntax_Syntax.Private -> true
                 | uu___1 -> false) quals in
          let quals2 q =
            let uu___ =
              (let uu___1 = FStar_Syntax_DsEnv.iface env in
               Prims.op_Negation uu___1) ||
                (FStar_Syntax_DsEnv.admitted_iface env) in
            if uu___
            then
              FStar_Compiler_List.op_At (FStar_Syntax_Syntax.Assumption :: q)
                quals1
            else FStar_Compiler_List.op_At q quals1 in
          FStar_Compiler_List.map
            (fun d ->
               let disc_name = FStar_Syntax_Util.mk_discriminator d in
               let uu___ = FStar_Ident.range_of_lid disc_name in
               let uu___1 =
                 quals2
                   [FStar_Syntax_Syntax.OnlyName;
                   FStar_Syntax_Syntax.Discriminator d] in
               let uu___2 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
               {
                 FStar_Syntax_Syntax.sigel =
                   (FStar_Syntax_Syntax.Sig_declare_typ
                      {
                        FStar_Syntax_Syntax.lid2 = disc_name;
                        FStar_Syntax_Syntax.us2 = [];
                        FStar_Syntax_Syntax.t2 = FStar_Syntax_Syntax.tun
                      });
                 FStar_Syntax_Syntax.sigrng = uu___;
                 FStar_Syntax_Syntax.sigquals = uu___1;
                 FStar_Syntax_Syntax.sigmeta =
                   FStar_Syntax_Syntax.default_sigmeta;
                 FStar_Syntax_Syntax.sigattrs = attrs;
                 FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                 FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
               }) datas
let (mk_indexed_projector_names :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_Syntax.fv_qual ->
      FStar_Syntax_Syntax.attribute Prims.list ->
        FStar_Syntax_DsEnv.env ->
          FStar_Ident.lident ->
            FStar_Syntax_Syntax.binder Prims.list ->
              FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun iquals ->
    fun fvq ->
      fun attrs ->
        fun env ->
          fun lid ->
            fun fields ->
              let p = FStar_Ident.range_of_lid lid in
              let uu___ =
                FStar_Compiler_List.mapi
                  (fun i ->
                     fun fld ->
                       let x = fld.FStar_Syntax_Syntax.binder_bv in
                       let field_name =
                         FStar_Syntax_Util.mk_field_projector_name lid x i in
                       let only_decl =
                         ((let uu___1 = FStar_Syntax_DsEnv.current_module env in
                           FStar_Ident.lid_equals
                             FStar_Parser_Const.prims_lid uu___1)
                            || (fvq <> FStar_Syntax_Syntax.Data_ctor))
                           ||
                           (FStar_Syntax_Util.has_attribute attrs
                              FStar_Parser_Const.no_auto_projectors_attr) in
                       let no_decl =
                         FStar_Syntax_Syntax.is_type
                           x.FStar_Syntax_Syntax.sort in
                       let quals q =
                         if only_decl
                         then FStar_Syntax_Syntax.Assumption :: q
                         else q in
                       let quals1 =
                         let iquals1 =
                           FStar_Compiler_List.filter
                             (fun uu___1 ->
                                match uu___1 with
                                | FStar_Syntax_Syntax.NoExtract -> true
                                | FStar_Syntax_Syntax.Private -> true
                                | uu___2 -> false) iquals in
                         quals (FStar_Syntax_Syntax.OnlyName ::
                           (FStar_Syntax_Syntax.Projector
                              (lid, (x.FStar_Syntax_Syntax.ppname))) ::
                           iquals1) in
                       let decl =
                         let uu___1 = FStar_Ident.range_of_lid field_name in
                         let uu___2 =
                           FStar_Syntax_DsEnv.opens_and_abbrevs env in
                         {
                           FStar_Syntax_Syntax.sigel =
                             (FStar_Syntax_Syntax.Sig_declare_typ
                                {
                                  FStar_Syntax_Syntax.lid2 = field_name;
                                  FStar_Syntax_Syntax.us2 = [];
                                  FStar_Syntax_Syntax.t2 =
                                    FStar_Syntax_Syntax.tun
                                });
                           FStar_Syntax_Syntax.sigrng = uu___1;
                           FStar_Syntax_Syntax.sigquals = quals1;
                           FStar_Syntax_Syntax.sigmeta =
                             FStar_Syntax_Syntax.default_sigmeta;
                           FStar_Syntax_Syntax.sigattrs = attrs;
                           FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                           FStar_Syntax_Syntax.sigopts =
                             FStar_Pervasives_Native.None
                         } in
                       if only_decl
                       then [decl]
                       else
                         (let lb =
                            let uu___2 =
                              let uu___3 =
                                FStar_Syntax_Syntax.lid_and_dd_as_fv
                                  field_name FStar_Pervasives_Native.None in
                              FStar_Pervasives.Inr uu___3 in
                            {
                              FStar_Syntax_Syntax.lbname = uu___2;
                              FStar_Syntax_Syntax.lbunivs = [];
                              FStar_Syntax_Syntax.lbtyp =
                                FStar_Syntax_Syntax.tun;
                              FStar_Syntax_Syntax.lbeff =
                                FStar_Parser_Const.effect_Tot_lid;
                              FStar_Syntax_Syntax.lbdef =
                                FStar_Syntax_Syntax.tun;
                              FStar_Syntax_Syntax.lbattrs = [];
                              FStar_Syntax_Syntax.lbpos =
                                FStar_Compiler_Range_Type.dummyRange
                            } in
                          let impl =
                            let uu___2 =
                              let uu___3 =
                                let uu___4 =
                                  let uu___5 =
                                    let uu___6 =
                                      FStar_Compiler_Util.right
                                        lb.FStar_Syntax_Syntax.lbname in
                                    (uu___6.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                  [uu___5] in
                                {
                                  FStar_Syntax_Syntax.lbs1 = (false, [lb]);
                                  FStar_Syntax_Syntax.lids1 = uu___4
                                } in
                              FStar_Syntax_Syntax.Sig_let uu___3 in
                            let uu___3 =
                              FStar_Syntax_DsEnv.opens_and_abbrevs env in
                            {
                              FStar_Syntax_Syntax.sigel = uu___2;
                              FStar_Syntax_Syntax.sigrng = p;
                              FStar_Syntax_Syntax.sigquals = quals1;
                              FStar_Syntax_Syntax.sigmeta =
                                FStar_Syntax_Syntax.default_sigmeta;
                              FStar_Syntax_Syntax.sigattrs = attrs;
                              FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                uu___3;
                              FStar_Syntax_Syntax.sigopts =
                                FStar_Pervasives_Native.None
                            } in
                          if no_decl then [impl] else [decl; impl])) fields in
              FStar_Compiler_List.flatten uu___
let (mk_data_projector_names :
  FStar_Syntax_Syntax.qualifier Prims.list ->
    FStar_Syntax_DsEnv.env ->
      FStar_Syntax_Syntax.sigelt -> FStar_Syntax_Syntax.sigelt Prims.list)
  =
  fun iquals ->
    fun env ->
      fun se ->
        if
          (FStar_Syntax_Util.has_attribute se.FStar_Syntax_Syntax.sigattrs
             FStar_Parser_Const.no_auto_projectors_decls_attr)
            ||
            (FStar_Syntax_Util.has_attribute se.FStar_Syntax_Syntax.sigattrs
               FStar_Parser_Const.meta_projectors_attr)
        then []
        else
          (match se.FStar_Syntax_Syntax.sigel with
           | FStar_Syntax_Syntax.Sig_datacon
               { FStar_Syntax_Syntax.lid1 = lid;
                 FStar_Syntax_Syntax.us1 = uu___; FStar_Syntax_Syntax.t1 = t;
                 FStar_Syntax_Syntax.ty_lid = uu___1;
                 FStar_Syntax_Syntax.num_ty_params = n;
                 FStar_Syntax_Syntax.mutuals1 = uu___2;
                 FStar_Syntax_Syntax.injective_type_params1 = uu___3;_}
               ->
               let uu___4 = FStar_Syntax_Util.arrow_formals t in
               (match uu___4 with
                | (formals, uu___5) ->
                    (match formals with
                     | [] -> []
                     | uu___6 ->
                         let filter_records uu___7 =
                           match uu___7 with
                           | FStar_Syntax_Syntax.RecordConstructor
                               (uu___8, fns) ->
                               FStar_Pervasives_Native.Some
                                 (FStar_Syntax_Syntax.Record_ctor (lid, fns))
                           | uu___8 -> FStar_Pervasives_Native.None in
                         let fv_qual =
                           let uu___7 =
                             FStar_Compiler_Util.find_map
                               se.FStar_Syntax_Syntax.sigquals filter_records in
                           match uu___7 with
                           | FStar_Pervasives_Native.None ->
                               FStar_Syntax_Syntax.Data_ctor
                           | FStar_Pervasives_Native.Some q -> q in
                         let uu___7 = FStar_Compiler_Util.first_N n formals in
                         (match uu___7 with
                          | (uu___8, rest) ->
                              mk_indexed_projector_names iquals fv_qual
                                se.FStar_Syntax_Syntax.sigattrs env lid rest)))
           | uu___ -> [])
let (mk_typ_abbrev :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Ident.lident ->
        FStar_Syntax_Syntax.univ_name Prims.list ->
          FStar_Syntax_Syntax.binders ->
            FStar_Syntax_Syntax.typ FStar_Pervasives_Native.option ->
              FStar_Syntax_Syntax.term' FStar_Syntax_Syntax.syntax ->
                FStar_Ident.lident Prims.list ->
                  FStar_Syntax_Syntax.qualifier Prims.list ->
                    FStar_Compiler_Range_Type.range ->
                      FStar_Syntax_Syntax.sigelt)
  =
  fun env ->
    fun d ->
      fun lid ->
        fun uvs ->
          fun typars ->
            fun kopt ->
              fun t ->
                fun lids ->
                  fun quals ->
                    fun rng ->
                      let attrs =
                        let uu___ =
                          FStar_Compiler_List.map (desugar_term env)
                            d.FStar_Parser_AST.attrs in
                        FStar_Syntax_Util.deduplicate_terms uu___ in
                      let val_attrs =
                        let uu___ =
                          FStar_Syntax_DsEnv.lookup_letbinding_quals_and_attrs
                            env lid in
                        FStar_Pervasives_Native.snd uu___ in
                      let lb =
                        let uu___ =
                          let uu___1 =
                            FStar_Syntax_Syntax.lid_and_dd_as_fv lid
                              FStar_Pervasives_Native.None in
                          FStar_Pervasives.Inr uu___1 in
                        let uu___1 =
                          if FStar_Compiler_Util.is_some kopt
                          then
                            let uu___2 =
                              let uu___3 = FStar_Compiler_Util.must kopt in
                              FStar_Syntax_Syntax.mk_Total uu___3 in
                            FStar_Syntax_Util.arrow typars uu___2
                          else FStar_Syntax_Syntax.tun in
                        let uu___2 = no_annot_abs typars t in
                        {
                          FStar_Syntax_Syntax.lbname = uu___;
                          FStar_Syntax_Syntax.lbunivs = uvs;
                          FStar_Syntax_Syntax.lbtyp = uu___1;
                          FStar_Syntax_Syntax.lbeff =
                            FStar_Parser_Const.effect_Tot_lid;
                          FStar_Syntax_Syntax.lbdef = uu___2;
                          FStar_Syntax_Syntax.lbattrs = [];
                          FStar_Syntax_Syntax.lbpos = rng
                        } in
                      let uu___ =
                        FStar_Syntax_Util.deduplicate_terms
                          (FStar_Compiler_List.op_At val_attrs attrs) in
                      let uu___1 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                      {
                        FStar_Syntax_Syntax.sigel =
                          (FStar_Syntax_Syntax.Sig_let
                             {
                               FStar_Syntax_Syntax.lbs1 = (false, [lb]);
                               FStar_Syntax_Syntax.lids1 = lids
                             });
                        FStar_Syntax_Syntax.sigrng = rng;
                        FStar_Syntax_Syntax.sigquals = quals;
                        FStar_Syntax_Syntax.sigmeta =
                          FStar_Syntax_Syntax.default_sigmeta;
                        FStar_Syntax_Syntax.sigattrs = uu___;
                        FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___1;
                        FStar_Syntax_Syntax.sigopts =
                          FStar_Pervasives_Native.None
                      }
let rec (desugar_tycon :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Syntax_Syntax.term Prims.list ->
        FStar_Syntax_Syntax.qualifier Prims.list ->
          FStar_Parser_AST.tycon Prims.list ->
            (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env ->
    fun d ->
      fun d_attrs_initial ->
        fun quals ->
          fun tcs ->
            let rng = d.FStar_Parser_AST.drange in
            let tycon_id uu___ =
              match uu___ with
              | FStar_Parser_AST.TyconAbstract (id, uu___1, uu___2) -> id
              | FStar_Parser_AST.TyconAbbrev (id, uu___1, uu___2, uu___3) ->
                  id
              | FStar_Parser_AST.TyconRecord
                  (id, uu___1, uu___2, uu___3, uu___4) -> id
              | FStar_Parser_AST.TyconVariant (id, uu___1, uu___2, uu___3) ->
                  id in
            let binder_to_term b =
              match b.FStar_Parser_AST.b with
              | FStar_Parser_AST.Annotated (x, uu___) ->
                  let uu___1 =
                    let uu___2 = FStar_Ident.lid_of_ids [x] in
                    FStar_Parser_AST.Var uu___2 in
                  let uu___2 = FStar_Ident.range_of_id x in
                  FStar_Parser_AST.mk_term uu___1 uu___2
                    FStar_Parser_AST.Expr
              | FStar_Parser_AST.Variable x ->
                  let uu___ =
                    let uu___1 = FStar_Ident.lid_of_ids [x] in
                    FStar_Parser_AST.Var uu___1 in
                  let uu___1 = FStar_Ident.range_of_id x in
                  FStar_Parser_AST.mk_term uu___ uu___1 FStar_Parser_AST.Expr
              | FStar_Parser_AST.TAnnotated (a, uu___) ->
                  let uu___1 = FStar_Ident.range_of_id a in
                  FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a) uu___1
                    FStar_Parser_AST.Type_level
              | FStar_Parser_AST.TVariable a ->
                  let uu___ = FStar_Ident.range_of_id a in
                  FStar_Parser_AST.mk_term (FStar_Parser_AST.Tvar a) uu___
                    FStar_Parser_AST.Type_level
              | FStar_Parser_AST.NoName t -> t in
            let desugar_tycon_variant_record uu___ =
              match uu___ with
              | FStar_Parser_AST.TyconVariant (id, bds, k, variants) ->
                  let uu___1 =
                    let uu___2 =
                      FStar_Compiler_List.map
                        (fun uu___3 ->
                           match uu___3 with
                           | (cid, payload, attrs) ->
                               (match payload with
                                | FStar_Pervasives_Native.Some
                                    (FStar_Parser_AST.VpRecord (r, k1)) ->
                                    let record_id =
                                      let uu___4 =
                                        let uu___5 =
                                          let uu___6 =
                                            FStar_Ident.string_of_id id in
                                          let uu___7 =
                                            let uu___8 =
                                              let uu___9 =
                                                FStar_Ident.string_of_id cid in
                                              Prims.strcat uu___9 "__payload" in
                                            Prims.strcat "__" uu___8 in
                                          Prims.strcat uu___6 uu___7 in
                                        let uu___6 =
                                          FStar_Ident.range_of_id cid in
                                        (uu___5, uu___6) in
                                      FStar_Ident.mk_ident uu___4 in
                                    let record_id_t =
                                      let uu___4 =
                                        let uu___5 =
                                          FStar_Ident.lid_of_ns_and_id []
                                            record_id in
                                        FStar_Parser_AST.Var uu___5 in
                                      let uu___5 =
                                        FStar_Ident.range_of_id cid in
                                      {
                                        FStar_Parser_AST.tm = uu___4;
                                        FStar_Parser_AST.range = uu___5;
                                        FStar_Parser_AST.level =
                                          FStar_Parser_AST.Type_level
                                      } in
                                    let payload_typ =
                                      let uu___4 =
                                        FStar_Compiler_List.map
                                          (fun bd ->
                                             let uu___5 = binder_to_term bd in
                                             (uu___5,
                                               FStar_Parser_AST.Nothing)) bds in
                                      let uu___5 =
                                        FStar_Ident.range_of_id record_id in
                                      FStar_Parser_AST.mkApp record_id_t
                                        uu___4 uu___5 in
                                    let desugar_marker =
                                      let range =
                                        FStar_Ident.range_of_id record_id in
                                      let desugar_attr_fv =
                                        {
                                          FStar_Syntax_Syntax.fv_name =
                                            {
                                              FStar_Syntax_Syntax.v =
                                                FStar_Parser_Const.desugar_of_variant_record_lid;
                                              FStar_Syntax_Syntax.p = range
                                            };
                                          FStar_Syntax_Syntax.fv_qual =
                                            FStar_Pervasives_Native.None
                                        } in
                                      let desugar_attr =
                                        FStar_Syntax_Syntax.mk
                                          (FStar_Syntax_Syntax.Tm_fvar
                                             desugar_attr_fv) range in
                                      let cid_as_constant =
                                        let uu___4 =
                                          let uu___5 =
                                            let uu___6 =
                                              FStar_Syntax_DsEnv.qualify env
                                                cid in
                                            FStar_Ident.string_of_lid uu___6 in
                                          FStar_Syntax_Embeddings_Base.embed
                                            FStar_Syntax_Embeddings.e_string
                                            uu___5 in
                                        uu___4 range
                                          FStar_Pervasives_Native.None
                                          FStar_Syntax_Embeddings_Base.id_norm_cb in
                                      FStar_Syntax_Syntax.mk_Tm_app
                                        desugar_attr
                                        [(cid_as_constant,
                                           FStar_Pervasives_Native.None)]
                                        range in
                                    let uu___4 =
                                      let uu___5 =
                                        let uu___6 =
                                          match k1 with
                                          | FStar_Pervasives_Native.None ->
                                              FStar_Parser_AST.VpOfNotation
                                                payload_typ
                                          | FStar_Pervasives_Native.Some k2
                                              ->
                                              let uu___7 =
                                                let uu___8 =
                                                  let uu___9 =
                                                    let uu___10 =
                                                      let uu___11 =
                                                        let uu___12 =
                                                          FStar_Ident.range_of_id
                                                            record_id in
                                                        FStar_Parser_AST.mk_binder
                                                          (FStar_Parser_AST.NoName
                                                             payload_typ)
                                                          uu___12
                                                          FStar_Parser_AST.Type_level
                                                          FStar_Pervasives_Native.None in
                                                      [uu___11] in
                                                    (uu___10, k2) in
                                                  FStar_Parser_AST.Product
                                                    uu___9 in
                                                {
                                                  FStar_Parser_AST.tm =
                                                    uu___8;
                                                  FStar_Parser_AST.range =
                                                    (payload_typ.FStar_Parser_AST.range);
                                                  FStar_Parser_AST.level =
                                                    FStar_Parser_AST.Type_level
                                                } in
                                              FStar_Parser_AST.VpArbitrary
                                                uu___7 in
                                        FStar_Pervasives_Native.Some uu___6 in
                                      (cid, uu___5, attrs) in
                                    ((FStar_Pervasives_Native.Some
                                        ((FStar_Parser_AST.TyconRecord
                                            (record_id, bds,
                                              FStar_Pervasives_Native.None,
                                              attrs, r)), (desugar_marker ::
                                          d_attrs_initial))), uu___4)
                                | uu___4 ->
                                    (FStar_Pervasives_Native.None,
                                      (cid, payload, attrs)))) variants in
                    FStar_Compiler_List.unzip uu___2 in
                  (match uu___1 with
                   | (additional_records, variants1) ->
                       let concat_options =
                         FStar_Compiler_List.filter_map (fun r -> r) in
                       let uu___2 = concat_options additional_records in
                       FStar_Compiler_List.op_At uu___2
                         [((FStar_Parser_AST.TyconVariant
                              (id, bds, k, variants1)), d_attrs_initial)])
              | tycon -> [(tycon, d_attrs_initial)] in
            let tcs1 =
              FStar_Compiler_List.concatMap desugar_tycon_variant_record tcs in
            let tot rng1 =
              FStar_Parser_AST.mk_term
                (FStar_Parser_AST.Name FStar_Parser_Const.effect_Tot_lid)
                rng1 FStar_Parser_AST.Expr in
            let with_constructor_effect t =
              let uu___ =
                let uu___1 =
                  let uu___2 = tot t.FStar_Parser_AST.range in
                  (uu___2, t, FStar_Parser_AST.Nothing) in
                FStar_Parser_AST.App uu___1 in
              FStar_Parser_AST.mk_term uu___ t.FStar_Parser_AST.range
                t.FStar_Parser_AST.level in
            let apply_binders t binders =
              let imp_of_aqual b =
                match b.FStar_Parser_AST.aqual with
                | FStar_Pervasives_Native.Some (FStar_Parser_AST.Implicit) ->
                    FStar_Parser_AST.Hash
                | FStar_Pervasives_Native.Some (FStar_Parser_AST.Meta uu___)
                    -> FStar_Parser_AST.Hash
                | FStar_Pervasives_Native.Some
                    (FStar_Parser_AST.TypeClassArg) -> FStar_Parser_AST.Hash
                | uu___ -> FStar_Parser_AST.Nothing in
              FStar_Compiler_List.fold_left
                (fun out ->
                   fun b ->
                     let uu___ =
                       let uu___1 =
                         let uu___2 = binder_to_term b in
                         (out, uu___2, (imp_of_aqual b)) in
                       FStar_Parser_AST.App uu___1 in
                     FStar_Parser_AST.mk_term uu___
                       out.FStar_Parser_AST.range out.FStar_Parser_AST.level)
                t binders in
            let tycon_record_as_variant uu___ =
              match uu___ with
              | FStar_Parser_AST.TyconRecord (id, parms, kopt, attrs, fields)
                  ->
                  let constrName =
                    let uu___1 =
                      let uu___2 =
                        let uu___3 = FStar_Ident.string_of_id id in
                        Prims.strcat "Mk" uu___3 in
                      let uu___3 = FStar_Ident.range_of_id id in
                      (uu___2, uu___3) in
                    FStar_Ident.mk_ident uu___1 in
                  let mfields =
                    FStar_Compiler_List.map
                      (fun uu___1 ->
                         match uu___1 with
                         | (x, q, attrs1, t) ->
                             let uu___2 = FStar_Ident.range_of_id x in
                             FStar_Parser_AST.mk_binder_with_attrs
                               (FStar_Parser_AST.Annotated (x, t)) uu___2
                               FStar_Parser_AST.Expr q attrs1) fields in
                  let result =
                    let uu___1 =
                      let uu___2 =
                        let uu___3 = FStar_Ident.lid_of_ids [id] in
                        FStar_Parser_AST.Var uu___3 in
                      let uu___3 = FStar_Ident.range_of_id id in
                      FStar_Parser_AST.mk_term uu___2 uu___3
                        FStar_Parser_AST.Type_level in
                    apply_binders uu___1 parms in
                  let constrTyp =
                    let uu___1 =
                      let uu___2 =
                        let uu___3 = with_constructor_effect result in
                        (mfields, uu___3) in
                      FStar_Parser_AST.Product uu___2 in
                    let uu___2 = FStar_Ident.range_of_id id in
                    FStar_Parser_AST.mk_term uu___1 uu___2
                      FStar_Parser_AST.Type_level in
                  let names =
                    let uu___1 = binder_idents parms in id :: uu___1 in
                  (FStar_Compiler_List.iter
                     (fun uu___2 ->
                        match uu___2 with
                        | (f, uu___3, uu___4, uu___5) ->
                            let uu___6 =
                              FStar_Compiler_Util.for_some
                                (fun i -> FStar_Ident.ident_equals f i) names in
                            if uu___6
                            then
                              let uu___7 =
                                let uu___8 = FStar_Ident.string_of_id f in
                                FStar_Compiler_Util.format1
                                  "Field %s shadows the record's name or a parameter of it, please rename it"
                                  uu___8 in
                              FStar_Errors.raise_error
                                FStar_Ident.hasrange_ident f
                                FStar_Errors_Codes.Error_FieldShadow ()
                                (Obj.magic
                                   FStar_Errors_Msg.is_error_message_string)
                                (Obj.magic uu___7)
                            else ()) fields;
                   (let uu___2 =
                      FStar_Compiler_List.map
                        (fun uu___3 ->
                           match uu___3 with
                           | (f, uu___4, uu___5, uu___6) -> f) fields in
                    ((FStar_Parser_AST.TyconVariant
                        (id, parms, kopt,
                          [(constrName,
                             (FStar_Pervasives_Native.Some
                                (FStar_Parser_AST.VpArbitrary constrTyp)),
                             attrs)])), uu___2)))
              | uu___1 -> FStar_Compiler_Effect.failwith "impossible" in
            let desugar_abstract_tc quals1 _env mutuals d_attrs uu___ =
              match uu___ with
              | FStar_Parser_AST.TyconAbstract (id, binders, kopt) ->
                  let uu___1 = typars_of_binders _env binders in
                  (match uu___1 with
                   | (_env', typars) ->
                       let k =
                         match kopt with
                         | FStar_Pervasives_Native.None ->
                             FStar_Syntax_Util.ktype
                         | FStar_Pervasives_Native.Some k1 ->
                             desugar_term _env' k1 in
                       let tconstr =
                         let uu___2 =
                           let uu___3 =
                             let uu___4 = FStar_Ident.lid_of_ids [id] in
                             FStar_Parser_AST.Var uu___4 in
                           let uu___4 = FStar_Ident.range_of_id id in
                           FStar_Parser_AST.mk_term uu___3 uu___4
                             FStar_Parser_AST.Type_level in
                         apply_binders uu___2 binders in
                       let qlid = FStar_Syntax_DsEnv.qualify _env id in
                       let typars1 = FStar_Syntax_Subst.close_binders typars in
                       let k1 = FStar_Syntax_Subst.close typars1 k in
                       let se =
                         let uu___2 = FStar_Ident.range_of_id id in
                         let uu___3 =
                           FStar_Syntax_DsEnv.opens_and_abbrevs env in
                         {
                           FStar_Syntax_Syntax.sigel =
                             (FStar_Syntax_Syntax.Sig_inductive_typ
                                {
                                  FStar_Syntax_Syntax.lid = qlid;
                                  FStar_Syntax_Syntax.us = [];
                                  FStar_Syntax_Syntax.params = typars1;
                                  FStar_Syntax_Syntax.num_uniform_params =
                                    FStar_Pervasives_Native.None;
                                  FStar_Syntax_Syntax.t = k1;
                                  FStar_Syntax_Syntax.mutuals = mutuals;
                                  FStar_Syntax_Syntax.ds = [];
                                  FStar_Syntax_Syntax.injective_type_params =
                                    false
                                });
                           FStar_Syntax_Syntax.sigrng = uu___2;
                           FStar_Syntax_Syntax.sigquals = quals1;
                           FStar_Syntax_Syntax.sigmeta =
                             FStar_Syntax_Syntax.default_sigmeta;
                           FStar_Syntax_Syntax.sigattrs = d_attrs;
                           FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___3;
                           FStar_Syntax_Syntax.sigopts =
                             FStar_Pervasives_Native.None
                         } in
                       let uu___2 =
                         FStar_Syntax_DsEnv.push_top_level_rec_binding _env
                           id in
                       (match uu___2 with
                        | (_env1, uu___3) ->
                            let uu___4 =
                              FStar_Syntax_DsEnv.push_top_level_rec_binding
                                _env' id in
                            (match uu___4 with
                             | (_env2, uu___5) -> (_env1, _env2, se, tconstr))))
              | uu___1 -> FStar_Compiler_Effect.failwith "Unexpected tycon" in
            let push_tparams env1 bs =
              let uu___ =
                FStar_Compiler_List.fold_left
                  (fun uu___1 ->
                     fun b ->
                       match uu___1 with
                       | (env2, tps) ->
                           let uu___2 =
                             FStar_Syntax_DsEnv.push_bv env2
                               (b.FStar_Syntax_Syntax.binder_bv).FStar_Syntax_Syntax.ppname in
                           (match uu___2 with
                            | (env3, y) ->
                                let uu___3 =
                                  let uu___4 =
                                    mk_binder_with_attrs y
                                      b.FStar_Syntax_Syntax.binder_qual
                                      b.FStar_Syntax_Syntax.binder_attrs in
                                  uu___4 :: tps in
                                (env3, uu___3))) (env1, []) bs in
              match uu___ with
              | (env2, bs1) -> (env2, (FStar_Compiler_List.rev bs1)) in
            match tcs1 with
            | (FStar_Parser_AST.TyconAbstract (id, bs, kopt), d_attrs)::[] ->
                let kopt1 =
                  match kopt with
                  | FStar_Pervasives_Native.None ->
                      let uu___ =
                        let uu___1 = FStar_Ident.range_of_id id in
                        tm_type_z uu___1 in
                      FStar_Pervasives_Native.Some uu___
                  | uu___ -> kopt in
                let tc = FStar_Parser_AST.TyconAbstract (id, bs, kopt1) in
                let uu___ = desugar_abstract_tc quals env [] d_attrs tc in
                (match uu___ with
                 | (uu___1, uu___2, se, uu___3) ->
                     let se1 =
                       match se.FStar_Syntax_Syntax.sigel with
                       | FStar_Syntax_Syntax.Sig_inductive_typ
                           { FStar_Syntax_Syntax.lid = l;
                             FStar_Syntax_Syntax.us = uu___4;
                             FStar_Syntax_Syntax.params = typars;
                             FStar_Syntax_Syntax.num_uniform_params = uu___5;
                             FStar_Syntax_Syntax.t = k;
                             FStar_Syntax_Syntax.mutuals = [];
                             FStar_Syntax_Syntax.ds = [];
                             FStar_Syntax_Syntax.injective_type_params =
                               uu___6;_}
                           ->
                           let quals1 = se.FStar_Syntax_Syntax.sigquals in
                           let quals2 =
                             if
                               FStar_Compiler_List.contains
                                 FStar_Syntax_Syntax.Assumption quals1
                             then quals1
                             else
                               ((let uu___9 =
                                   let uu___10 = FStar_Options.ml_ish () in
                                   Prims.op_Negation uu___10 in
                                 if uu___9
                                 then
                                   let uu___10 =
                                     let uu___11 =
                                       FStar_Class_Show.show
                                         FStar_Ident.showable_lident l in
                                     FStar_Compiler_Util.format1
                                       "Adding an implicit 'assume new' qualifier on %s"
                                       uu___11 in
                                   FStar_Errors.log_issue
                                     FStar_Syntax_Syntax.has_range_sigelt se
                                     FStar_Errors_Codes.Warning_AddImplicitAssumeNewQualifier
                                     ()
                                     (Obj.magic
                                        FStar_Errors_Msg.is_error_message_string)
                                     (Obj.magic uu___10)
                                 else ());
                                FStar_Syntax_Syntax.Assumption
                                ::
                                FStar_Syntax_Syntax.New
                                ::
                                quals1) in
                           let t =
                             match typars with
                             | [] -> k
                             | uu___7 ->
                                 let uu___8 =
                                   let uu___9 =
                                     let uu___10 =
                                       FStar_Syntax_Syntax.mk_Total k in
                                     {
                                       FStar_Syntax_Syntax.bs1 = typars;
                                       FStar_Syntax_Syntax.comp = uu___10
                                     } in
                                   FStar_Syntax_Syntax.Tm_arrow uu___9 in
                                 FStar_Syntax_Syntax.mk uu___8
                                   se.FStar_Syntax_Syntax.sigrng in
                           {
                             FStar_Syntax_Syntax.sigel =
                               (FStar_Syntax_Syntax.Sig_declare_typ
                                  {
                                    FStar_Syntax_Syntax.lid2 = l;
                                    FStar_Syntax_Syntax.us2 = [];
                                    FStar_Syntax_Syntax.t2 = t
                                  });
                             FStar_Syntax_Syntax.sigrng =
                               (se.FStar_Syntax_Syntax.sigrng);
                             FStar_Syntax_Syntax.sigquals = quals2;
                             FStar_Syntax_Syntax.sigmeta =
                               (se.FStar_Syntax_Syntax.sigmeta);
                             FStar_Syntax_Syntax.sigattrs =
                               (se.FStar_Syntax_Syntax.sigattrs);
                             FStar_Syntax_Syntax.sigopens_and_abbrevs =
                               (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                             FStar_Syntax_Syntax.sigopts =
                               (se.FStar_Syntax_Syntax.sigopts)
                           }
                       | uu___4 ->
                           FStar_Compiler_Effect.failwith "Impossible" in
                     let env1 = FStar_Syntax_DsEnv.push_sigelt env se1 in
                     (env1, [se1]))
            | (FStar_Parser_AST.TyconAbbrev (id, binders, kopt, t), _d_attrs)::[]
                ->
                let uu___ = typars_of_binders env binders in
                (match uu___ with
                 | (env', typars) ->
                     let kopt1 =
                       match kopt with
                       | FStar_Pervasives_Native.None ->
                           let uu___1 =
                             FStar_Compiler_Util.for_some
                               (fun uu___2 ->
                                  match uu___2 with
                                  | FStar_Syntax_Syntax.Effect -> true
                                  | uu___3 -> false) quals in
                           if uu___1
                           then
                             FStar_Pervasives_Native.Some
                               FStar_Syntax_Syntax.teff
                           else FStar_Pervasives_Native.None
                       | FStar_Pervasives_Native.Some k ->
                           let uu___1 = desugar_term env' k in
                           FStar_Pervasives_Native.Some uu___1 in
                     let t0 = t in
                     let quals1 =
                       let uu___1 =
                         FStar_Compiler_Util.for_some
                           (fun uu___2 ->
                              match uu___2 with
                              | FStar_Syntax_Syntax.Logic -> true
                              | uu___3 -> false) quals in
                       if uu___1
                       then quals
                       else
                         if
                           t0.FStar_Parser_AST.level =
                             FStar_Parser_AST.Formula
                         then FStar_Syntax_Syntax.Logic :: quals
                         else quals in
                     let qlid = FStar_Syntax_DsEnv.qualify env id in
                     let se =
                       if
                         FStar_Compiler_List.contains
                           FStar_Syntax_Syntax.Effect quals1
                       then
                         let uu___1 =
                           let uu___2 =
                             let uu___3 = unparen t in
                             uu___3.FStar_Parser_AST.tm in
                           match uu___2 with
                           | FStar_Parser_AST.Construct (head, args) ->
                               let uu___3 =
                                 match FStar_Compiler_List.rev args with
                                 | (last_arg, uu___4)::args_rev ->
                                     let uu___5 =
                                       let uu___6 = unparen last_arg in
                                       uu___6.FStar_Parser_AST.tm in
                                     (match uu___5 with
                                      | FStar_Parser_AST.Attributes ts ->
                                          (ts,
                                            (FStar_Compiler_List.rev args_rev))
                                      | uu___6 -> ([], args))
                                 | uu___4 -> ([], args) in
                               (match uu___3 with
                                | (cattributes, args1) ->
                                    let uu___4 =
                                      FStar_Parser_AST.mk_term
                                        (FStar_Parser_AST.Construct
                                           (head, args1))
                                        t.FStar_Parser_AST.range
                                        t.FStar_Parser_AST.level in
                                    let uu___5 =
                                      desugar_attributes env cattributes in
                                    (uu___4, uu___5))
                           | uu___3 -> (t, []) in
                         match uu___1 with
                         | (t1, cattributes) ->
                             let c =
                               desugar_comp t1.FStar_Parser_AST.range false
                                 env' t1 in
                             let typars1 =
                               FStar_Syntax_Subst.close_binders typars in
                             let c1 = FStar_Syntax_Subst.close_comp typars1 c in
                             let quals2 =
                               FStar_Compiler_List.filter
                                 (fun uu___2 ->
                                    match uu___2 with
                                    | FStar_Syntax_Syntax.Effect -> false
                                    | uu___3 -> true) quals1 in
                             let uu___2 = FStar_Ident.range_of_id id in
                             let uu___3 =
                               FStar_Syntax_DsEnv.opens_and_abbrevs env in
                             {
                               FStar_Syntax_Syntax.sigel =
                                 (FStar_Syntax_Syntax.Sig_effect_abbrev
                                    {
                                      FStar_Syntax_Syntax.lid4 = qlid;
                                      FStar_Syntax_Syntax.us4 = [];
                                      FStar_Syntax_Syntax.bs2 = typars1;
                                      FStar_Syntax_Syntax.comp1 = c1;
                                      FStar_Syntax_Syntax.cflags =
                                        (FStar_Compiler_List.op_At
                                           cattributes
                                           (FStar_Syntax_Util.comp_flags c1))
                                    });
                               FStar_Syntax_Syntax.sigrng = uu___2;
                               FStar_Syntax_Syntax.sigquals = quals2;
                               FStar_Syntax_Syntax.sigmeta =
                                 FStar_Syntax_Syntax.default_sigmeta;
                               FStar_Syntax_Syntax.sigattrs = [];
                               FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                 uu___3;
                               FStar_Syntax_Syntax.sigopts =
                                 FStar_Pervasives_Native.None
                             }
                       else
                         (let t1 = desugar_typ env' t in
                          let uu___2 = FStar_Ident.range_of_id id in
                          mk_typ_abbrev env d qlid [] typars kopt1 t1 
                            [qlid] quals1 uu___2) in
                     let env1 = FStar_Syntax_DsEnv.push_sigelt env se in
                     (env1, [se]))
            | (FStar_Parser_AST.TyconRecord payload, d_attrs)::[] ->
                let trec = FStar_Parser_AST.TyconRecord payload in
                let uu___ = tycon_record_as_variant trec in
                (match uu___ with
                 | (t, fs) ->
                     let uu___1 =
                       let uu___2 =
                         let uu___3 =
                           let uu___4 =
                             let uu___5 =
                               FStar_Syntax_DsEnv.current_module env in
                             FStar_Ident.ids_of_lid uu___5 in
                           (uu___4, fs) in
                         FStar_Syntax_Syntax.RecordType uu___3 in
                       uu___2 :: quals in
                     desugar_tycon env d d_attrs uu___1 [t])
            | uu___::uu___1 ->
                let env0 = env in
                let mutuals =
                  FStar_Compiler_List.map
                    (fun uu___2 ->
                       match uu___2 with
                       | (x, uu___3) ->
                           FStar_Syntax_DsEnv.qualify env (tycon_id x)) tcs1 in
                let rec collect_tcs quals1 et uu___2 =
                  match uu___2 with
                  | (tc, d_attrs) ->
                      let uu___3 = et in
                      (match uu___3 with
                       | (env1, tcs2) ->
                           (match tc with
                            | FStar_Parser_AST.TyconRecord uu___4 ->
                                let trec = tc in
                                let uu___5 = tycon_record_as_variant trec in
                                (match uu___5 with
                                 | (t, fs) ->
                                     let uu___6 =
                                       let uu___7 =
                                         let uu___8 =
                                           let uu___9 =
                                             let uu___10 =
                                               FStar_Syntax_DsEnv.current_module
                                                 env1 in
                                             FStar_Ident.ids_of_lid uu___10 in
                                           (uu___9, fs) in
                                         FStar_Syntax_Syntax.RecordType
                                           uu___8 in
                                       uu___7 :: quals1 in
                                     collect_tcs uu___6 (env1, tcs2)
                                       (t, d_attrs))
                            | FStar_Parser_AST.TyconVariant
                                (id, binders, kopt, constructors) ->
                                let uu___4 =
                                  desugar_abstract_tc quals1 env1 mutuals
                                    d_attrs
                                    (FStar_Parser_AST.TyconAbstract
                                       (id, binders, kopt)) in
                                (match uu___4 with
                                 | (env2, uu___5, se, tconstr) ->
                                     (env2,
                                       (((FStar_Pervasives.Inl
                                            (se, constructors, tconstr,
                                              quals1)), d_attrs) :: tcs2)))
                            | FStar_Parser_AST.TyconAbbrev
                                (id, binders, kopt, t) ->
                                let uu___4 =
                                  desugar_abstract_tc quals1 env1 mutuals
                                    d_attrs
                                    (FStar_Parser_AST.TyconAbstract
                                       (id, binders, kopt)) in
                                (match uu___4 with
                                 | (env2, uu___5, se, tconstr) ->
                                     (env2,
                                       (((FStar_Pervasives.Inr
                                            (se, binders, t, quals1)),
                                          d_attrs) :: tcs2)))
                            | uu___4 ->
                                FStar_Errors.raise_error
                                  FStar_Class_HasRange.hasRange_range rng
                                  FStar_Errors_Codes.Fatal_NonInductiveInMutuallyDefinedType
                                  ()
                                  (Obj.magic
                                     FStar_Errors_Msg.is_error_message_string)
                                  (Obj.magic
                                     "Mutually defined type contains a non-inductive element"))) in
                let uu___2 =
                  FStar_Compiler_List.fold_left (collect_tcs quals) (env, [])
                    tcs1 in
                (match uu___2 with
                 | (env1, tcs2) ->
                     let tcs3 = FStar_Compiler_List.rev tcs2 in
                     let tps_sigelts =
                       FStar_Compiler_List.collect
                         (fun uu___3 ->
                            match uu___3 with
                            | (tc, d_attrs) ->
                                (match tc with
                                 | FStar_Pervasives.Inr
                                     ({
                                        FStar_Syntax_Syntax.sigel =
                                          FStar_Syntax_Syntax.Sig_inductive_typ
                                          { FStar_Syntax_Syntax.lid = id;
                                            FStar_Syntax_Syntax.us = uvs;
                                            FStar_Syntax_Syntax.params =
                                              tpars;
                                            FStar_Syntax_Syntax.num_uniform_params
                                              = uu___4;
                                            FStar_Syntax_Syntax.t = k;
                                            FStar_Syntax_Syntax.mutuals =
                                              uu___5;
                                            FStar_Syntax_Syntax.ds = uu___6;
                                            FStar_Syntax_Syntax.injective_type_params
                                              = uu___7;_};
                                        FStar_Syntax_Syntax.sigrng = uu___8;
                                        FStar_Syntax_Syntax.sigquals = uu___9;
                                        FStar_Syntax_Syntax.sigmeta = uu___10;
                                        FStar_Syntax_Syntax.sigattrs =
                                          uu___11;
                                        FStar_Syntax_Syntax.sigopens_and_abbrevs
                                          = uu___12;
                                        FStar_Syntax_Syntax.sigopts = uu___13;_},
                                      binders, t, quals1)
                                     ->
                                     let t1 =
                                       let uu___14 =
                                         typars_of_binders env1 binders in
                                       match uu___14 with
                                       | (env2, tpars1) ->
                                           let uu___15 =
                                             push_tparams env2 tpars1 in
                                           (match uu___15 with
                                            | (env_tps, tpars2) ->
                                                let t2 =
                                                  desugar_typ env_tps t in
                                                let tpars3 =
                                                  FStar_Syntax_Subst.close_binders
                                                    tpars2 in
                                                FStar_Syntax_Subst.close
                                                  tpars3 t2) in
                                     let uu___14 =
                                       let uu___15 =
                                         let uu___16 =
                                           FStar_Ident.range_of_lid id in
                                         mk_typ_abbrev env1 d id uvs tpars
                                           (FStar_Pervasives_Native.Some k)
                                           t1 [id] quals1 uu___16 in
                                       ([], uu___15) in
                                     [uu___14]
                                 | FStar_Pervasives.Inl
                                     ({
                                        FStar_Syntax_Syntax.sigel =
                                          FStar_Syntax_Syntax.Sig_inductive_typ
                                          { FStar_Syntax_Syntax.lid = tname;
                                            FStar_Syntax_Syntax.us = univs;
                                            FStar_Syntax_Syntax.params =
                                              tpars;
                                            FStar_Syntax_Syntax.num_uniform_params
                                              = num_uniform;
                                            FStar_Syntax_Syntax.t = k;
                                            FStar_Syntax_Syntax.mutuals =
                                              mutuals1;
                                            FStar_Syntax_Syntax.ds = uu___4;
                                            FStar_Syntax_Syntax.injective_type_params
                                              = injective_type_params;_};
                                        FStar_Syntax_Syntax.sigrng = uu___5;
                                        FStar_Syntax_Syntax.sigquals =
                                          tname_quals;
                                        FStar_Syntax_Syntax.sigmeta = uu___6;
                                        FStar_Syntax_Syntax.sigattrs = uu___7;
                                        FStar_Syntax_Syntax.sigopens_and_abbrevs
                                          = uu___8;
                                        FStar_Syntax_Syntax.sigopts = uu___9;_},
                                      constrs, tconstr, quals1)
                                     ->
                                     let mk_tot t =
                                       let tot1 =
                                         FStar_Parser_AST.mk_term
                                           (FStar_Parser_AST.Name
                                              FStar_Parser_Const.effect_Tot_lid)
                                           t.FStar_Parser_AST.range
                                           t.FStar_Parser_AST.level in
                                       FStar_Parser_AST.mk_term
                                         (FStar_Parser_AST.App
                                            (tot1, t,
                                              FStar_Parser_AST.Nothing))
                                         t.FStar_Parser_AST.range
                                         t.FStar_Parser_AST.level in
                                     let tycon = (tname, tpars, k) in
                                     let uu___10 = push_tparams env1 tpars in
                                     (match uu___10 with
                                      | (env_tps, tps) ->
                                          let data_tpars =
                                            FStar_Compiler_List.map
                                              (fun tp ->
                                                 {
                                                   FStar_Syntax_Syntax.binder_bv
                                                     =
                                                     (tp.FStar_Syntax_Syntax.binder_bv);
                                                   FStar_Syntax_Syntax.binder_qual
                                                     =
                                                     (FStar_Pervasives_Native.Some
                                                        (FStar_Syntax_Syntax.Implicit
                                                           true));
                                                   FStar_Syntax_Syntax.binder_positivity
                                                     =
                                                     (tp.FStar_Syntax_Syntax.binder_positivity);
                                                   FStar_Syntax_Syntax.binder_attrs
                                                     =
                                                     (tp.FStar_Syntax_Syntax.binder_attrs)
                                                 }) tps in
                                          let tot_tconstr = mk_tot tconstr in
                                          let val_attrs =
                                            let uu___11 =
                                              FStar_Syntax_DsEnv.lookup_letbinding_quals_and_attrs
                                                env0 tname in
                                            FStar_Pervasives_Native.snd
                                              uu___11 in
                                          let uu___11 =
                                            let uu___12 =
                                              FStar_Compiler_List.map
                                                (fun uu___13 ->
                                                   match uu___13 with
                                                   | (id, payload,
                                                      cons_attrs) ->
                                                       let t =
                                                         match payload with
                                                         | FStar_Pervasives_Native.Some
                                                             (FStar_Parser_AST.VpArbitrary
                                                             t1) -> t1
                                                         | FStar_Pervasives_Native.Some
                                                             (FStar_Parser_AST.VpOfNotation
                                                             t1) ->
                                                             let uu___14 =
                                                               let uu___15 =
                                                                 let uu___16
                                                                   =
                                                                   let uu___17
                                                                    =
                                                                    FStar_Parser_AST.mk_binder
                                                                    (FStar_Parser_AST.NoName
                                                                    t1)
                                                                    t1.FStar_Parser_AST.range
                                                                    t1.FStar_Parser_AST.level
                                                                    FStar_Pervasives_Native.None in
                                                                   [uu___17] in
                                                                 (uu___16,
                                                                   tot_tconstr) in
                                                               FStar_Parser_AST.Product
                                                                 uu___15 in
                                                             FStar_Parser_AST.mk_term
                                                               uu___14
                                                               t1.FStar_Parser_AST.range
                                                               t1.FStar_Parser_AST.level
                                                         | FStar_Pervasives_Native.Some
                                                             (FStar_Parser_AST.VpRecord
                                                             uu___14) ->
                                                             FStar_Compiler_Effect.failwith
                                                               "Impossible: [VpRecord _] should have disappeared after [desugar_tycon_variant_record]"
                                                         | FStar_Pervasives_Native.None
                                                             ->
                                                             let uu___14 =
                                                               FStar_Ident.range_of_id
                                                                 id in
                                                             {
                                                               FStar_Parser_AST.tm
                                                                 =
                                                                 (tconstr.FStar_Parser_AST.tm);
                                                               FStar_Parser_AST.range
                                                                 = uu___14;
                                                               FStar_Parser_AST.level
                                                                 =
                                                                 (tconstr.FStar_Parser_AST.level)
                                                             } in
                                                       let t1 =
                                                         let uu___14 =
                                                           close env_tps t in
                                                         desugar_term env_tps
                                                           uu___14 in
                                                       let name =
                                                         FStar_Syntax_DsEnv.qualify
                                                           env1 id in
                                                       let quals2 =
                                                         FStar_Compiler_List.collect
                                                           (fun uu___14 ->
                                                              match uu___14
                                                              with
                                                              | FStar_Syntax_Syntax.RecordType
                                                                  fns ->
                                                                  [FStar_Syntax_Syntax.RecordConstructor
                                                                    fns]
                                                              | uu___15 -> [])
                                                           tname_quals in
                                                       let ntps =
                                                         FStar_Compiler_List.length
                                                           data_tpars in
                                                       let uu___14 =
                                                         let uu___15 =
                                                           let uu___16 =
                                                             let uu___17 =
                                                               let uu___18 =
                                                                 let uu___19
                                                                   =
                                                                   let uu___20
                                                                    =
                                                                    FStar_Syntax_Util.name_function_binders
                                                                    t1 in
                                                                   FStar_Syntax_Syntax.mk_Total
                                                                    uu___20 in
                                                                 FStar_Syntax_Util.arrow
                                                                   data_tpars
                                                                   uu___19 in
                                                               {
                                                                 FStar_Syntax_Syntax.lid1
                                                                   = name;
                                                                 FStar_Syntax_Syntax.us1
                                                                   = univs;
                                                                 FStar_Syntax_Syntax.t1
                                                                   = uu___18;
                                                                 FStar_Syntax_Syntax.ty_lid
                                                                   = tname;
                                                                 FStar_Syntax_Syntax.num_ty_params
                                                                   = ntps;
                                                                 FStar_Syntax_Syntax.mutuals1
                                                                   = mutuals1;
                                                                 FStar_Syntax_Syntax.injective_type_params1
                                                                   =
                                                                   injective_type_params
                                                               } in
                                                             FStar_Syntax_Syntax.Sig_datacon
                                                               uu___17 in
                                                           let uu___17 =
                                                             FStar_Ident.range_of_lid
                                                               name in
                                                           let uu___18 =
                                                             let uu___19 =
                                                               let uu___20 =
                                                                 let uu___21
                                                                   =
                                                                   FStar_Compiler_List.map
                                                                    (desugar_term
                                                                    env1)
                                                                    cons_attrs in
                                                                 FStar_Compiler_List.op_At
                                                                   d_attrs
                                                                   uu___21 in
                                                               FStar_Compiler_List.op_At
                                                                 val_attrs
                                                                 uu___20 in
                                                             FStar_Syntax_Util.deduplicate_terms
                                                               uu___19 in
                                                           let uu___19 =
                                                             FStar_Syntax_DsEnv.opens_and_abbrevs
                                                               env1 in
                                                           {
                                                             FStar_Syntax_Syntax.sigel
                                                               = uu___16;
                                                             FStar_Syntax_Syntax.sigrng
                                                               = uu___17;
                                                             FStar_Syntax_Syntax.sigquals
                                                               = quals2;
                                                             FStar_Syntax_Syntax.sigmeta
                                                               =
                                                               FStar_Syntax_Syntax.default_sigmeta;
                                                             FStar_Syntax_Syntax.sigattrs
                                                               = uu___18;
                                                             FStar_Syntax_Syntax.sigopens_and_abbrevs
                                                               = uu___19;
                                                             FStar_Syntax_Syntax.sigopts
                                                               =
                                                               FStar_Pervasives_Native.None
                                                           } in
                                                         (tps, uu___15) in
                                                       (name, uu___14))
                                                constrs in
                                            FStar_Compiler_List.split uu___12 in
                                          (match uu___11 with
                                           | (constrNames, constrs1) ->
                                               ((let uu___13 =
                                                   FStar_Compiler_Effect.op_Bang
                                                     dbg_attrs in
                                                 if uu___13
                                                 then
                                                   let uu___14 =
                                                     FStar_Class_Show.show
                                                       FStar_Ident.showable_lident
                                                       tname in
                                                   let uu___15 =
                                                     FStar_Class_Show.show
                                                       (FStar_Class_Show.show_list
                                                          FStar_Syntax_Print.showable_term)
                                                       val_attrs in
                                                   let uu___16 =
                                                     FStar_Class_Show.show
                                                       (FStar_Class_Show.show_list
                                                          FStar_Syntax_Print.showable_term)
                                                       d_attrs in
                                                   FStar_Compiler_Util.print3
                                                     "Adding attributes to type %s: val_attrs=[@@%s] attrs=[@@%s]\n"
                                                     uu___14 uu___15 uu___16
                                                 else ());
                                                (let uu___13 =
                                                   let uu___14 =
                                                     let uu___15 =
                                                       FStar_Ident.range_of_lid
                                                         tname in
                                                     let uu___16 =
                                                       FStar_Syntax_Util.deduplicate_terms
                                                         (FStar_Compiler_List.op_At
                                                            val_attrs d_attrs) in
                                                     let uu___17 =
                                                       FStar_Syntax_DsEnv.opens_and_abbrevs
                                                         env1 in
                                                     {
                                                       FStar_Syntax_Syntax.sigel
                                                         =
                                                         (FStar_Syntax_Syntax.Sig_inductive_typ
                                                            {
                                                              FStar_Syntax_Syntax.lid
                                                                = tname;
                                                              FStar_Syntax_Syntax.us
                                                                = univs;
                                                              FStar_Syntax_Syntax.params
                                                                = tpars;
                                                              FStar_Syntax_Syntax.num_uniform_params
                                                                = num_uniform;
                                                              FStar_Syntax_Syntax.t
                                                                = k;
                                                              FStar_Syntax_Syntax.mutuals
                                                                = mutuals1;
                                                              FStar_Syntax_Syntax.ds
                                                                = constrNames;
                                                              FStar_Syntax_Syntax.injective_type_params
                                                                =
                                                                injective_type_params
                                                            });
                                                       FStar_Syntax_Syntax.sigrng
                                                         = uu___15;
                                                       FStar_Syntax_Syntax.sigquals
                                                         = tname_quals;
                                                       FStar_Syntax_Syntax.sigmeta
                                                         =
                                                         FStar_Syntax_Syntax.default_sigmeta;
                                                       FStar_Syntax_Syntax.sigattrs
                                                         = uu___16;
                                                       FStar_Syntax_Syntax.sigopens_and_abbrevs
                                                         = uu___17;
                                                       FStar_Syntax_Syntax.sigopts
                                                         =
                                                         FStar_Pervasives_Native.None
                                                     } in
                                                   ([], uu___14) in
                                                 uu___13 :: constrs1))))
                                 | uu___4 ->
                                     FStar_Compiler_Effect.failwith
                                       "impossible")) tcs3 in
                     let sigelts =
                       FStar_Compiler_List.map
                         (fun uu___3 ->
                            match uu___3 with | (uu___4, se) -> se)
                         tps_sigelts in
                     let uu___3 =
                       let uu___4 =
                         FStar_Compiler_List.collect
                           FStar_Syntax_Util.lids_of_sigelt sigelts in
                       FStar_Syntax_MutRecTy.disentangle_abbrevs_from_bundle
                         sigelts quals uu___4 rng in
                     (match uu___3 with
                      | (bundle, abbrevs) ->
                          ((let uu___5 =
                              FStar_Compiler_Effect.op_Bang dbg_attrs in
                            if uu___5
                            then
                              let uu___6 =
                                FStar_Class_Show.show
                                  FStar_Syntax_Print.showable_sigelt bundle in
                              FStar_Compiler_Util.print1
                                "After disentangling: %s\n" uu___6
                            else ());
                           (let env2 =
                              FStar_Syntax_DsEnv.push_sigelt env0 bundle in
                            let env3 =
                              FStar_Compiler_List.fold_left
                                FStar_Syntax_DsEnv.push_sigelt env2 abbrevs in
                            let data_ops =
                              FStar_Compiler_List.collect
                                (fun uu___5 ->
                                   match uu___5 with
                                   | (tps, se) ->
                                       mk_data_projector_names quals env3 se)
                                tps_sigelts in
                            let discs =
                              FStar_Compiler_List.collect
                                (fun se ->
                                   match se.FStar_Syntax_Syntax.sigel with
                                   | FStar_Syntax_Syntax.Sig_inductive_typ
                                       { FStar_Syntax_Syntax.lid = tname;
                                         FStar_Syntax_Syntax.us = uu___5;
                                         FStar_Syntax_Syntax.params = tps;
                                         FStar_Syntax_Syntax.num_uniform_params
                                           = uu___6;
                                         FStar_Syntax_Syntax.t = k;
                                         FStar_Syntax_Syntax.mutuals = uu___7;
                                         FStar_Syntax_Syntax.ds = constrs;
                                         FStar_Syntax_Syntax.injective_type_params
                                           = uu___8;_}
                                       ->
                                       let quals1 =
                                         se.FStar_Syntax_Syntax.sigquals in
                                       let uu___9 =
                                         FStar_Compiler_List.filter
                                           (fun data_lid ->
                                              let data_quals =
                                                let data_se =
                                                  let uu___10 =
                                                    FStar_Compiler_List.find
                                                      (fun se1 ->
                                                         match se1.FStar_Syntax_Syntax.sigel
                                                         with
                                                         | FStar_Syntax_Syntax.Sig_datacon
                                                             {
                                                               FStar_Syntax_Syntax.lid1
                                                                 = name;
                                                               FStar_Syntax_Syntax.us1
                                                                 = uu___11;
                                                               FStar_Syntax_Syntax.t1
                                                                 = uu___12;
                                                               FStar_Syntax_Syntax.ty_lid
                                                                 = uu___13;
                                                               FStar_Syntax_Syntax.num_ty_params
                                                                 = uu___14;
                                                               FStar_Syntax_Syntax.mutuals1
                                                                 = uu___15;
                                                               FStar_Syntax_Syntax.injective_type_params1
                                                                 = uu___16;_}
                                                             ->
                                                             FStar_Ident.lid_equals
                                                               name data_lid
                                                         | uu___11 -> false)
                                                      sigelts in
                                                  FStar_Compiler_Util.must
                                                    uu___10 in
                                                data_se.FStar_Syntax_Syntax.sigquals in
                                              let uu___10 =
                                                FStar_Compiler_List.existsb
                                                  (fun uu___11 ->
                                                     match uu___11 with
                                                     | FStar_Syntax_Syntax.RecordConstructor
                                                         uu___12 -> true
                                                     | uu___12 -> false)
                                                  data_quals in
                                              Prims.op_Negation uu___10)
                                           constrs in
                                       mk_data_discriminators quals1 env3
                                         uu___9
                                         se.FStar_Syntax_Syntax.sigattrs
                                   | uu___5 -> []) sigelts in
                            let ops =
                              FStar_Compiler_List.op_At discs data_ops in
                            let env4 =
                              FStar_Compiler_List.fold_left
                                FStar_Syntax_DsEnv.push_sigelt env3 ops in
                            (env4,
                              (FStar_Compiler_List.op_At [bundle]
                                 (FStar_Compiler_List.op_At abbrevs ops)))))))
            | [] -> FStar_Compiler_Effect.failwith "impossible"
let (desugar_binders :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.binder Prims.list ->
      (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.binder Prims.list))
  =
  fun env ->
    fun binders ->
      let uu___ =
        FStar_Compiler_List.fold_left
          (fun uu___1 ->
             fun b ->
               match uu___1 with
               | (env1, binders1) ->
                   let uu___2 = desugar_binder env1 b in
                   (match uu___2 with
                    | (FStar_Pervasives_Native.Some a, k, attrs) ->
                        let uu___3 =
                          as_binder env1 b.FStar_Parser_AST.aqual
                            ((FStar_Pervasives_Native.Some a), k, attrs) in
                        (match uu___3 with
                         | (binder, env2) -> (env2, (binder :: binders1)))
                    | uu___3 ->
                        FStar_Errors.raise_error
                          FStar_Parser_AST.hasRange_binder b
                          FStar_Errors_Codes.Fatal_MissingNameInBinder ()
                          (Obj.magic FStar_Errors_Msg.is_error_message_string)
                          (Obj.magic "Missing name in binder"))) (env, [])
          binders in
      match uu___ with
      | (env1, binders1) -> (env1, (FStar_Compiler_List.rev binders1))
let (push_reflect_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Syntax_Syntax.qualifier Prims.list ->
      FStar_Ident.lid ->
        FStar_Compiler_Range_Type.range -> FStar_Syntax_DsEnv.env)
  =
  fun env ->
    fun quals ->
      fun effect_name ->
        fun range ->
          let uu___ =
            FStar_Compiler_Util.for_some
              (fun uu___1 ->
                 match uu___1 with
                 | FStar_Syntax_Syntax.Reflectable uu___2 -> true
                 | uu___2 -> false) quals in
          if uu___
          then
            let monad_env =
              let uu___1 = FStar_Ident.ident_of_lid effect_name in
              FStar_Syntax_DsEnv.enter_monad_scope env uu___1 in
            let reflect_lid =
              let uu___1 = FStar_Ident.id_of_text "reflect" in
              FStar_Syntax_DsEnv.qualify monad_env uu___1 in
            let quals1 =
              [FStar_Syntax_Syntax.Assumption;
              FStar_Syntax_Syntax.Reflectable effect_name] in
            let refl_decl =
              let uu___1 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_declare_typ
                     {
                       FStar_Syntax_Syntax.lid2 = reflect_lid;
                       FStar_Syntax_Syntax.us2 = [];
                       FStar_Syntax_Syntax.t2 = FStar_Syntax_Syntax.tun
                     });
                FStar_Syntax_Syntax.sigrng = range;
                FStar_Syntax_Syntax.sigquals = quals1;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = [];
                FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___1;
                FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
              } in
            FStar_Syntax_DsEnv.push_sigelt env refl_decl
          else env
let (parse_attr_with_list :
  Prims.bool ->
    FStar_Syntax_Syntax.term ->
      FStar_Ident.lident ->
        (Prims.int Prims.list FStar_Pervasives_Native.option * Prims.bool))
  =
  fun warn ->
    fun at ->
      fun head ->
        let warn1 uu___ =
          if warn
          then
            let uu___1 =
              let uu___2 = FStar_Ident.string_of_lid head in
              FStar_Compiler_Util.format1
                "Found ill-applied '%s', argument should be a non-empty list of integer literals"
                uu___2 in
            FStar_Errors.log_issue (FStar_Syntax_Syntax.has_range_syntax ())
              at FStar_Errors_Codes.Warning_UnappliedFail ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic uu___1)
          else () in
        let uu___ = FStar_Syntax_Util.head_and_args at in
        match uu___ with
        | (hd, args) ->
            let uu___1 =
              let uu___2 = FStar_Syntax_Subst.compress hd in
              uu___2.FStar_Syntax_Syntax.n in
            (match uu___1 with
             | FStar_Syntax_Syntax.Tm_fvar fv when
                 FStar_Syntax_Syntax.fv_eq_lid fv head ->
                 (match args with
                  | [] -> ((FStar_Pervasives_Native.Some []), true)
                  | (a1, uu___2)::[] ->
                      let uu___3 =
                        FStar_Syntax_Embeddings_Base.unembed
                          (FStar_Syntax_Embeddings.e_list
                             FStar_Syntax_Embeddings.e_int) a1
                          FStar_Syntax_Embeddings_Base.id_norm_cb in
                      (match uu___3 with
                       | FStar_Pervasives_Native.Some es ->
                           let uu___4 =
                             let uu___5 =
                               FStar_Compiler_List.map FStar_BigInt.to_int_fs
                                 es in
                             FStar_Pervasives_Native.Some uu___5 in
                           (uu___4, true)
                       | uu___4 ->
                           (warn1 (); (FStar_Pervasives_Native.None, true)))
                  | uu___2 ->
                      (warn1 (); (FStar_Pervasives_Native.None, true)))
             | uu___2 -> (FStar_Pervasives_Native.None, false))
let (get_fail_attr1 :
  Prims.bool ->
    FStar_Syntax_Syntax.term ->
      (Prims.int Prims.list * Prims.bool) FStar_Pervasives_Native.option)
  =
  fun warn ->
    fun at ->
      let rebind res b =
        match res with
        | FStar_Pervasives_Native.None -> FStar_Pervasives_Native.None
        | FStar_Pervasives_Native.Some l ->
            FStar_Pervasives_Native.Some (l, b) in
      let uu___ = parse_attr_with_list warn at FStar_Parser_Const.fail_attr in
      match uu___ with
      | (res, matched) ->
          if matched
          then rebind res false
          else
            (let uu___2 =
               parse_attr_with_list warn at FStar_Parser_Const.fail_lax_attr in
             match uu___2 with | (res1, uu___3) -> rebind res1 true)
let (get_fail_attr :
  Prims.bool ->
    FStar_Syntax_Syntax.term Prims.list ->
      (Prims.int Prims.list * Prims.bool) FStar_Pervasives_Native.option)
  =
  fun warn ->
    fun ats ->
      let comb f1 f2 =
        match (f1, f2) with
        | (FStar_Pervasives_Native.Some (e1, l1),
           FStar_Pervasives_Native.Some (e2, l2)) ->
            FStar_Pervasives_Native.Some
              ((FStar_Compiler_List.op_At e1 e2), (l1 || l2))
        | (FStar_Pervasives_Native.Some (e, l), FStar_Pervasives_Native.None)
            -> FStar_Pervasives_Native.Some (e, l)
        | (FStar_Pervasives_Native.None, FStar_Pervasives_Native.Some (e, l))
            -> FStar_Pervasives_Native.Some (e, l)
        | uu___ -> FStar_Pervasives_Native.None in
      FStar_Compiler_List.fold_right
        (fun at ->
           fun acc -> let uu___ = get_fail_attr1 warn at in comb uu___ acc)
        ats FStar_Pervasives_Native.None
let (lookup_effect_lid :
  FStar_Syntax_DsEnv.env ->
    FStar_Ident.lident ->
      FStar_Compiler_Range_Type.range -> FStar_Syntax_Syntax.eff_decl)
  =
  fun env ->
    fun l ->
      fun r ->
        let uu___ = FStar_Syntax_DsEnv.try_lookup_effect_defn env l in
        match uu___ with
        | FStar_Pervasives_Native.None ->
            let uu___1 =
              let uu___2 =
                let uu___3 =
                  FStar_Class_Show.show FStar_Ident.showable_lident l in
                Prims.strcat uu___3 " not found" in
              Prims.strcat "Effect name " uu___2 in
            FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range r
              FStar_Errors_Codes.Fatal_EffectNotFound ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic uu___1)
        | FStar_Pervasives_Native.Some l1 -> l1
let rec (desugar_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Syntax_Syntax.term Prims.list ->
        FStar_Parser_AST.qualifiers ->
          Prims.bool ->
            FStar_Ident.ident ->
              FStar_Parser_AST.binder Prims.list ->
                FStar_Parser_AST.term ->
                  FStar_Parser_AST.decl Prims.list ->
                    (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.sigelt
                      Prims.list))
  =
  fun env ->
    fun d ->
      fun d_attrs ->
        fun quals ->
          fun is_layered ->
            fun eff_name ->
              fun eff_binders ->
                fun eff_typ ->
                  fun eff_decls ->
                    let env0 = env in
                    let monad_env =
                      FStar_Syntax_DsEnv.enter_monad_scope env eff_name in
                    let uu___ = desugar_binders monad_env eff_binders in
                    match uu___ with
                    | (env1, binders) ->
                        let eff_t = desugar_term env1 eff_typ in
                        let num_indices =
                          let uu___1 =
                            let uu___2 =
                              FStar_Syntax_Util.arrow_formals eff_t in
                            FStar_Pervasives_Native.fst uu___2 in
                          FStar_Compiler_List.length uu___1 in
                        let for_free =
                          (num_indices = Prims.int_one) &&
                            (Prims.op_Negation is_layered) in
                        (if for_free
                         then
                           (let uu___2 =
                              let uu___3 = FStar_Ident.string_of_id eff_name in
                              FStar_Compiler_Util.format1
                                "DM4Free feature is deprecated and will be removed soon, use layered effects to define %s"
                                uu___3 in
                            FStar_Errors.log_issue
                              FStar_Parser_AST.hasRange_decl d
                              FStar_Errors_Codes.Warning_DeprecatedGeneric ()
                              (Obj.magic
                                 FStar_Errors_Msg.is_error_message_string)
                              (Obj.magic uu___2))
                         else ();
                         (let mandatory_members =
                            let rr_members = ["repr"; "return"; "bind"] in
                            if for_free
                            then rr_members
                            else
                              if is_layered
                              then
                                FStar_Compiler_List.op_At rr_members
                                  ["subcomp"; "if_then_else"; "close"]
                              else
                                FStar_Compiler_List.op_At rr_members
                                  ["return_wp";
                                  "bind_wp";
                                  "if_then_else";
                                  "ite_wp";
                                  "stronger";
                                  "close_wp";
                                  "trivial"] in
                          let name_of_eff_decl decl =
                            match decl.FStar_Parser_AST.d with
                            | FStar_Parser_AST.Tycon
                                (uu___2, uu___3,
                                 (FStar_Parser_AST.TyconAbbrev
                                 (name, uu___4, uu___5, uu___6))::[])
                                -> FStar_Ident.string_of_id name
                            | uu___2 ->
                                FStar_Compiler_Effect.failwith
                                  "Malformed effect member declaration." in
                          let uu___2 =
                            FStar_Compiler_List.partition
                              (fun decl ->
                                 let uu___3 = name_of_eff_decl decl in
                                 FStar_Compiler_List.mem uu___3
                                   mandatory_members) eff_decls in
                          match uu___2 with
                          | (mandatory_members_decls, actions) ->
                              let uu___3 =
                                FStar_Compiler_List.fold_left
                                  (fun uu___4 ->
                                     fun decl ->
                                       match uu___4 with
                                       | (env2, out) ->
                                           let uu___5 =
                                             desugar_decl env2 decl in
                                           (match uu___5 with
                                            | (env3, ses) ->
                                                let uu___6 =
                                                  let uu___7 =
                                                    FStar_Compiler_List.hd
                                                      ses in
                                                  uu___7 :: out in
                                                (env3, uu___6))) (env1, [])
                                  mandatory_members_decls in
                              (match uu___3 with
                               | (env2, decls) ->
                                   let binders1 =
                                     FStar_Syntax_Subst.close_binders binders in
                                   let actions1 =
                                     FStar_Compiler_List.map
                                       (fun d1 ->
                                          match d1.FStar_Parser_AST.d with
                                          | FStar_Parser_AST.Tycon
                                              (uu___4, uu___5,
                                               (FStar_Parser_AST.TyconAbbrev
                                               (name, action_params, uu___6,
                                                {
                                                  FStar_Parser_AST.tm =
                                                    FStar_Parser_AST.Construct
                                                    (uu___7,
                                                     (def, uu___8)::(cps_type,
                                                                    uu___9)::[]);
                                                  FStar_Parser_AST.range =
                                                    uu___10;
                                                  FStar_Parser_AST.level =
                                                    uu___11;_}))::[])
                                              when Prims.op_Negation for_free
                                              ->
                                              let uu___12 =
                                                desugar_binders env2
                                                  action_params in
                                              (match uu___12 with
                                               | (env3, action_params1) ->
                                                   let action_params2 =
                                                     FStar_Syntax_Subst.close_binders
                                                       action_params1 in
                                                   let uu___13 =
                                                     FStar_Syntax_DsEnv.qualify
                                                       env3 name in
                                                   let uu___14 =
                                                     let uu___15 =
                                                       desugar_term env3 def in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_Compiler_List.op_At
                                                          binders1
                                                          action_params2)
                                                       uu___15 in
                                                   let uu___15 =
                                                     let uu___16 =
                                                       desugar_typ env3
                                                         cps_type in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_Compiler_List.op_At
                                                          binders1
                                                          action_params2)
                                                       uu___16 in
                                                   {
                                                     FStar_Syntax_Syntax.action_name
                                                       = uu___13;
                                                     FStar_Syntax_Syntax.action_unqualified_name
                                                       = name;
                                                     FStar_Syntax_Syntax.action_univs
                                                       = [];
                                                     FStar_Syntax_Syntax.action_params
                                                       = action_params2;
                                                     FStar_Syntax_Syntax.action_defn
                                                       = uu___14;
                                                     FStar_Syntax_Syntax.action_typ
                                                       = uu___15
                                                   })
                                          | FStar_Parser_AST.Tycon
                                              (uu___4, uu___5,
                                               (FStar_Parser_AST.TyconAbbrev
                                               (name, action_params, uu___6,
                                                defn))::[])
                                              when for_free || is_layered ->
                                              let uu___7 =
                                                desugar_binders env2
                                                  action_params in
                                              (match uu___7 with
                                               | (env3, action_params1) ->
                                                   let action_params2 =
                                                     FStar_Syntax_Subst.close_binders
                                                       action_params1 in
                                                   let uu___8 =
                                                     FStar_Syntax_DsEnv.qualify
                                                       env3 name in
                                                   let uu___9 =
                                                     let uu___10 =
                                                       desugar_term env3 defn in
                                                     FStar_Syntax_Subst.close
                                                       (FStar_Compiler_List.op_At
                                                          binders1
                                                          action_params2)
                                                       uu___10 in
                                                   {
                                                     FStar_Syntax_Syntax.action_name
                                                       = uu___8;
                                                     FStar_Syntax_Syntax.action_unqualified_name
                                                       = name;
                                                     FStar_Syntax_Syntax.action_univs
                                                       = [];
                                                     FStar_Syntax_Syntax.action_params
                                                       = action_params2;
                                                     FStar_Syntax_Syntax.action_defn
                                                       = uu___9;
                                                     FStar_Syntax_Syntax.action_typ
                                                       =
                                                       FStar_Syntax_Syntax.tun
                                                   })
                                          | uu___4 ->
                                              FStar_Errors.raise_error
                                                FStar_Parser_AST.hasRange_decl
                                                d1
                                                FStar_Errors_Codes.Fatal_MalformedActionDeclaration
                                                ()
                                                (Obj.magic
                                                   FStar_Errors_Msg.is_error_message_string)
                                                (Obj.magic
                                                   "Malformed action declaration; if this is an \"effect for free\", just provide the direct-style declaration. If this is not an \"effect for free\", please provide a pair of the definition and its cps-type with arrows inserted in the right place (see examples)."))
                                       actions in
                                   let eff_t1 =
                                     FStar_Syntax_Subst.close binders1 eff_t in
                                   let lookup s =
                                     let l =
                                       let uu___4 =
                                         FStar_Ident.mk_ident
                                           (s, (d.FStar_Parser_AST.drange)) in
                                       FStar_Syntax_DsEnv.qualify env2 uu___4 in
                                     let uu___4 =
                                       let uu___5 =
                                         FStar_Syntax_DsEnv.fail_or env2
                                           (FStar_Syntax_DsEnv.try_lookup_definition
                                              env2) l in
                                       FStar_Syntax_Subst.close binders1
                                         uu___5 in
                                     ([], uu___4) in
                                   let mname =
                                     FStar_Syntax_DsEnv.qualify env0 eff_name in
                                   let qualifiers =
                                     FStar_Compiler_List.map
                                       (trans_qual d.FStar_Parser_AST.drange
                                          (FStar_Pervasives_Native.Some mname))
                                       quals in
                                   let dummy_tscheme =
                                     ([], FStar_Syntax_Syntax.tun) in
                                   let uu___4 =
                                     if for_free
                                     then
                                       let uu___5 =
                                         let uu___6 =
                                           let uu___7 =
                                             let uu___8 = lookup "repr" in
                                             FStar_Pervasives_Native.Some
                                               uu___8 in
                                           let uu___8 =
                                             let uu___9 = lookup "return" in
                                             FStar_Pervasives_Native.Some
                                               uu___9 in
                                           let uu___9 =
                                             let uu___10 = lookup "bind" in
                                             FStar_Pervasives_Native.Some
                                               uu___10 in
                                           {
                                             FStar_Syntax_Syntax.ret_wp =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.bind_wp =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.stronger =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.if_then_else
                                               = dummy_tscheme;
                                             FStar_Syntax_Syntax.ite_wp =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.close_wp =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.trivial =
                                               dummy_tscheme;
                                             FStar_Syntax_Syntax.repr =
                                               uu___7;
                                             FStar_Syntax_Syntax.return_repr
                                               = uu___8;
                                             FStar_Syntax_Syntax.bind_repr =
                                               uu___9
                                           } in
                                         FStar_Syntax_Syntax.DM4F_eff uu___6 in
                                       ((FStar_Syntax_Syntax.WP_eff_sig
                                           ([], eff_t1)), uu___5)
                                     else
                                       if is_layered
                                       then
                                         (let has_subcomp =
                                            FStar_Compiler_List.existsb
                                              (fun decl ->
                                                 let uu___6 =
                                                   name_of_eff_decl decl in
                                                 uu___6 = "subcomp")
                                              eff_decls in
                                          let has_if_then_else =
                                            FStar_Compiler_List.existsb
                                              (fun decl ->
                                                 let uu___6 =
                                                   name_of_eff_decl decl in
                                                 uu___6 = "if_then_else")
                                              eff_decls in
                                          let has_close =
                                            FStar_Compiler_List.existsb
                                              (fun decl ->
                                                 let uu___6 =
                                                   name_of_eff_decl decl in
                                                 uu___6 = "close") eff_decls in
                                          let to_comb uu___6 =
                                            match uu___6 with
                                            | (us, t) ->
                                                ((us, t), dummy_tscheme,
                                                  FStar_Pervasives_Native.None) in
                                          let uu___6 =
                                            let uu___7 =
                                              let uu___8 =
                                                FStar_Syntax_Subst.compress
                                                  eff_t1 in
                                              uu___8.FStar_Syntax_Syntax.n in
                                            match uu___7 with
                                            | FStar_Syntax_Syntax.Tm_arrow
                                                {
                                                  FStar_Syntax_Syntax.bs1 =
                                                    bs;
                                                  FStar_Syntax_Syntax.comp =
                                                    c;_}
                                                ->
                                                let uu___8 = bs in
                                                (match uu___8 with
                                                 | a::bs1 ->
                                                     let uu___9 =
                                                       FStar_Compiler_List.fold_left
                                                         (fun uu___10 ->
                                                            fun b ->
                                                              match uu___10
                                                              with
                                                              | (n,
                                                                 allow_param,
                                                                 bs2) ->
                                                                  let b_attrs
                                                                    =
                                                                    b.FStar_Syntax_Syntax.binder_attrs in
                                                                  let is_param
                                                                    =
                                                                    FStar_Syntax_Util.has_attribute
                                                                    b_attrs
                                                                    FStar_Parser_Const.effect_parameter_attr in
                                                                  (if
                                                                    is_param
                                                                    &&
                                                                    (Prims.op_Negation
                                                                    allow_param)
                                                                   then
                                                                    FStar_Errors.raise_error
                                                                    FStar_Parser_AST.hasRange_decl
                                                                    d
                                                                    FStar_Errors_Codes.Fatal_UnexpectedEffect
                                                                    ()
                                                                    (Obj.magic
                                                                    FStar_Errors_Msg.is_error_message_string)
                                                                    (Obj.magic
                                                                    "Effect parameters must all be upfront")
                                                                   else ();
                                                                   (let b_attrs1
                                                                    =
                                                                    FStar_Syntax_Util.remove_attr
                                                                    FStar_Parser_Const.effect_parameter_attr
                                                                    b_attrs in
                                                                    ((if
                                                                    is_param
                                                                    then
                                                                    n +
                                                                    Prims.int_one
                                                                    else n),
                                                                    (allow_param
                                                                    &&
                                                                    is_param),
                                                                    (FStar_Compiler_List.op_At
                                                                    bs2
                                                                    [
                                                                    {
                                                                    FStar_Syntax_Syntax.binder_bv
                                                                    =
                                                                    (b.FStar_Syntax_Syntax.binder_bv);
                                                                    FStar_Syntax_Syntax.binder_qual
                                                                    =
                                                                    (b.FStar_Syntax_Syntax.binder_qual);
                                                                    FStar_Syntax_Syntax.binder_positivity
                                                                    =
                                                                    (b.FStar_Syntax_Syntax.binder_positivity);
                                                                    FStar_Syntax_Syntax.binder_attrs
                                                                    =
                                                                    b_attrs1
                                                                    }])))))
                                                         (Prims.int_zero,
                                                           true, []) bs1 in
                                                     (match uu___9 with
                                                      | (n, uu___10, bs2) ->
                                                          ({
                                                             FStar_Syntax_Syntax.n
                                                               =
                                                               (FStar_Syntax_Syntax.Tm_arrow
                                                                  {
                                                                    FStar_Syntax_Syntax.bs1
                                                                    = (a ::
                                                                    bs2);
                                                                    FStar_Syntax_Syntax.comp
                                                                    = c
                                                                  });
                                                             FStar_Syntax_Syntax.pos
                                                               =
                                                               (eff_t1.FStar_Syntax_Syntax.pos);
                                                             FStar_Syntax_Syntax.vars
                                                               =
                                                               (eff_t1.FStar_Syntax_Syntax.vars);
                                                             FStar_Syntax_Syntax.hash_code
                                                               =
                                                               (eff_t1.FStar_Syntax_Syntax.hash_code)
                                                           }, n)))
                                            | uu___8 ->
                                                FStar_Compiler_Effect.failwith
                                                  "desugaring indexed effect: effect type not an arrow" in
                                          match uu___6 with
                                          | (eff_t2, num_effect_params) ->
                                              let uu___7 =
                                                let uu___8 =
                                                  let uu___9 =
                                                    let uu___10 =
                                                      lookup "repr" in
                                                    (uu___10, dummy_tscheme) in
                                                  let uu___10 =
                                                    let uu___11 =
                                                      lookup "return" in
                                                    (uu___11, dummy_tscheme) in
                                                  let uu___11 =
                                                    let uu___12 =
                                                      lookup "bind" in
                                                    to_comb uu___12 in
                                                  let uu___12 =
                                                    if has_subcomp
                                                    then
                                                      let uu___13 =
                                                        lookup "subcomp" in
                                                      to_comb uu___13
                                                    else
                                                      (dummy_tscheme,
                                                        dummy_tscheme,
                                                        FStar_Pervasives_Native.None) in
                                                  let uu___13 =
                                                    if has_if_then_else
                                                    then
                                                      let uu___14 =
                                                        lookup "if_then_else" in
                                                      to_comb uu___14
                                                    else
                                                      (dummy_tscheme,
                                                        dummy_tscheme,
                                                        FStar_Pervasives_Native.None) in
                                                  let uu___14 =
                                                    if has_close
                                                    then
                                                      let uu___15 =
                                                        let uu___16 =
                                                          lookup "close" in
                                                        (uu___16,
                                                          dummy_tscheme) in
                                                      FStar_Pervasives_Native.Some
                                                        uu___15
                                                    else
                                                      FStar_Pervasives_Native.None in
                                                  {
                                                    FStar_Syntax_Syntax.l_repr
                                                      = uu___9;
                                                    FStar_Syntax_Syntax.l_return
                                                      = uu___10;
                                                    FStar_Syntax_Syntax.l_bind
                                                      = uu___11;
                                                    FStar_Syntax_Syntax.l_subcomp
                                                      = uu___12;
                                                    FStar_Syntax_Syntax.l_if_then_else
                                                      = uu___13;
                                                    FStar_Syntax_Syntax.l_close
                                                      = uu___14
                                                  } in
                                                FStar_Syntax_Syntax.Layered_eff
                                                  uu___8 in
                                              ((FStar_Syntax_Syntax.Layered_eff_sig
                                                  (num_effect_params,
                                                    ([], eff_t2))), uu___7))
                                       else
                                         (let rr =
                                            FStar_Compiler_Util.for_some
                                              (fun uu___7 ->
                                                 match uu___7 with
                                                 | FStar_Syntax_Syntax.Reifiable
                                                     -> true
                                                 | FStar_Syntax_Syntax.Reflectable
                                                     uu___8 -> true
                                                 | uu___8 -> false)
                                              qualifiers in
                                          let uu___7 =
                                            let uu___8 =
                                              let uu___9 = lookup "return_wp" in
                                              let uu___10 = lookup "bind_wp" in
                                              let uu___11 = lookup "stronger" in
                                              let uu___12 =
                                                lookup "if_then_else" in
                                              let uu___13 = lookup "ite_wp" in
                                              let uu___14 = lookup "close_wp" in
                                              let uu___15 = lookup "trivial" in
                                              let uu___16 =
                                                if rr
                                                then
                                                  let uu___17 = lookup "repr" in
                                                  FStar_Pervasives_Native.Some
                                                    uu___17
                                                else
                                                  FStar_Pervasives_Native.None in
                                              let uu___17 =
                                                if rr
                                                then
                                                  let uu___18 =
                                                    lookup "return" in
                                                  FStar_Pervasives_Native.Some
                                                    uu___18
                                                else
                                                  FStar_Pervasives_Native.None in
                                              let uu___18 =
                                                if rr
                                                then
                                                  let uu___19 = lookup "bind" in
                                                  FStar_Pervasives_Native.Some
                                                    uu___19
                                                else
                                                  FStar_Pervasives_Native.None in
                                              {
                                                FStar_Syntax_Syntax.ret_wp =
                                                  uu___9;
                                                FStar_Syntax_Syntax.bind_wp =
                                                  uu___10;
                                                FStar_Syntax_Syntax.stronger
                                                  = uu___11;
                                                FStar_Syntax_Syntax.if_then_else
                                                  = uu___12;
                                                FStar_Syntax_Syntax.ite_wp =
                                                  uu___13;
                                                FStar_Syntax_Syntax.close_wp
                                                  = uu___14;
                                                FStar_Syntax_Syntax.trivial =
                                                  uu___15;
                                                FStar_Syntax_Syntax.repr =
                                                  uu___16;
                                                FStar_Syntax_Syntax.return_repr
                                                  = uu___17;
                                                FStar_Syntax_Syntax.bind_repr
                                                  = uu___18
                                              } in
                                            FStar_Syntax_Syntax.Primitive_eff
                                              uu___8 in
                                          ((FStar_Syntax_Syntax.WP_eff_sig
                                              ([], eff_t1)), uu___7)) in
                                   (match uu___4 with
                                    | (eff_sig, combinators) ->
                                        let extraction_mode =
                                          if is_layered
                                          then
                                            FStar_Syntax_Syntax.Extract_none
                                              ""
                                          else
                                            if for_free
                                            then
                                              (let uu___6 =
                                                 FStar_Compiler_Util.for_some
                                                   (fun uu___7 ->
                                                      match uu___7 with
                                                      | FStar_Syntax_Syntax.Reifiable
                                                          -> true
                                                      | uu___8 -> false)
                                                   qualifiers in
                                               if uu___6
                                               then
                                                 FStar_Syntax_Syntax.Extract_reify
                                               else
                                                 FStar_Syntax_Syntax.Extract_primitive)
                                            else
                                              FStar_Syntax_Syntax.Extract_primitive in
                                        let sigel =
                                          FStar_Syntax_Syntax.Sig_new_effect
                                            {
                                              FStar_Syntax_Syntax.mname =
                                                mname;
                                              FStar_Syntax_Syntax.cattributes
                                                = [];
                                              FStar_Syntax_Syntax.univs = [];
                                              FStar_Syntax_Syntax.binders =
                                                binders1;
                                              FStar_Syntax_Syntax.signature =
                                                eff_sig;
                                              FStar_Syntax_Syntax.combinators
                                                = combinators;
                                              FStar_Syntax_Syntax.actions =
                                                actions1;
                                              FStar_Syntax_Syntax.eff_attrs =
                                                d_attrs;
                                              FStar_Syntax_Syntax.extraction_mode
                                                = extraction_mode
                                            } in
                                        let se =
                                          let uu___5 =
                                            FStar_Syntax_DsEnv.opens_and_abbrevs
                                              env2 in
                                          {
                                            FStar_Syntax_Syntax.sigel = sigel;
                                            FStar_Syntax_Syntax.sigrng =
                                              (d.FStar_Parser_AST.drange);
                                            FStar_Syntax_Syntax.sigquals =
                                              qualifiers;
                                            FStar_Syntax_Syntax.sigmeta =
                                              FStar_Syntax_Syntax.default_sigmeta;
                                            FStar_Syntax_Syntax.sigattrs =
                                              d_attrs;
                                            FStar_Syntax_Syntax.sigopens_and_abbrevs
                                              = uu___5;
                                            FStar_Syntax_Syntax.sigopts =
                                              FStar_Pervasives_Native.None
                                          } in
                                        let env3 =
                                          FStar_Syntax_DsEnv.push_sigelt env0
                                            se in
                                        let env4 =
                                          FStar_Compiler_List.fold_left
                                            (fun env5 ->
                                               fun a ->
                                                 let uu___5 =
                                                   FStar_Syntax_Util.action_as_lb
                                                     mname a
                                                     (a.FStar_Syntax_Syntax.action_defn).FStar_Syntax_Syntax.pos in
                                                 FStar_Syntax_DsEnv.push_sigelt
                                                   env5 uu___5) env3 actions1 in
                                        let env5 =
                                          push_reflect_effect env4 qualifiers
                                            mname d.FStar_Parser_AST.drange in
                                        (env5, [se])))))
and (desugar_redefine_effect :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl ->
      FStar_Syntax_Syntax.attribute Prims.list ->
        (FStar_Ident.lident FStar_Pervasives_Native.option ->
           FStar_Parser_AST.qualifier -> FStar_Syntax_Syntax.qualifier)
          ->
          FStar_Parser_AST.qualifier Prims.list ->
            FStar_Ident.ident ->
              FStar_Parser_AST.binder Prims.list ->
                FStar_Parser_AST.term ->
                  (FStar_Syntax_DsEnv.env * FStar_Syntax_Syntax.sigelt
                    Prims.list))
  =
  fun env ->
    fun d ->
      fun d_attrs ->
        fun trans_qual1 ->
          fun quals ->
            fun eff_name ->
              fun eff_binders ->
                fun defn ->
                  let env0 = env in
                  let env1 =
                    FStar_Syntax_DsEnv.enter_monad_scope env eff_name in
                  let uu___ = desugar_binders env1 eff_binders in
                  match uu___ with
                  | (env2, binders) ->
                      let uu___1 =
                        let uu___2 = head_and_args defn in
                        match uu___2 with
                        | (head, args) ->
                            let lid =
                              match head.FStar_Parser_AST.tm with
                              | FStar_Parser_AST.Name l -> l
                              | uu___3 ->
                                  let uu___4 =
                                    let uu___5 =
                                      let uu___6 =
                                        FStar_Parser_AST.term_to_string head in
                                      Prims.strcat uu___6 " not found" in
                                    Prims.strcat "Effect " uu___5 in
                                  FStar_Errors.raise_error
                                    FStar_Parser_AST.hasRange_decl d
                                    FStar_Errors_Codes.Fatal_EffectNotFound
                                    ()
                                    (Obj.magic
                                       FStar_Errors_Msg.is_error_message_string)
                                    (Obj.magic uu___4) in
                            let ed =
                              FStar_Syntax_DsEnv.fail_or env2
                                (FStar_Syntax_DsEnv.try_lookup_effect_defn
                                   env2) lid in
                            let uu___3 =
                              match FStar_Compiler_List.rev args with
                              | (last_arg, uu___4)::args_rev ->
                                  let uu___5 =
                                    let uu___6 = unparen last_arg in
                                    uu___6.FStar_Parser_AST.tm in
                                  (match uu___5 with
                                   | FStar_Parser_AST.Attributes ts ->
                                       (ts,
                                         (FStar_Compiler_List.rev args_rev))
                                   | uu___6 -> ([], args))
                              | uu___4 -> ([], args) in
                            (match uu___3 with
                             | (cattributes, args1) ->
                                 let uu___4 = desugar_args env2 args1 in
                                 let uu___5 =
                                   desugar_attributes env2 cattributes in
                                 (lid, ed, uu___4, uu___5)) in
                      (match uu___1 with
                       | (ed_lid, ed, args, cattributes) ->
                           let binders1 =
                             FStar_Syntax_Subst.close_binders binders in
                           (if
                              (FStar_Compiler_List.length args) <>
                                (FStar_Compiler_List.length
                                   ed.FStar_Syntax_Syntax.binders)
                            then
                              FStar_Errors.raise_error
                                FStar_Parser_AST.hasRange_term defn
                                FStar_Errors_Codes.Fatal_ArgumentLengthMismatch
                                ()
                                (Obj.magic
                                   FStar_Errors_Msg.is_error_message_string)
                                (Obj.magic
                                   "Unexpected number of arguments to effect constructor")
                            else ();
                            (let uu___3 =
                               FStar_Syntax_Subst.open_term'
                                 ed.FStar_Syntax_Syntax.binders
                                 FStar_Syntax_Syntax.t_unit in
                             match uu___3 with
                             | (ed_binders, uu___4, ed_binders_opening) ->
                                 let sub' shift_n uu___5 =
                                   match uu___5 with
                                   | (us, x) ->
                                       let x1 =
                                         let uu___6 =
                                           FStar_Syntax_Subst.shift_subst
                                             (shift_n +
                                                (FStar_Compiler_List.length
                                                   us)) ed_binders_opening in
                                         FStar_Syntax_Subst.subst uu___6 x in
                                       let s =
                                         FStar_Syntax_Util.subst_of_list
                                           ed_binders args in
                                       let uu___6 =
                                         let uu___7 =
                                           FStar_Syntax_Subst.subst s x1 in
                                         (us, uu___7) in
                                       FStar_Syntax_Subst.close_tscheme
                                         binders1 uu___6 in
                                 let sub = sub' Prims.int_zero in
                                 let mname =
                                   FStar_Syntax_DsEnv.qualify env0 eff_name in
                                 let ed1 =
                                   let uu___5 =
                                     FStar_Syntax_Util.apply_eff_sig sub
                                       ed.FStar_Syntax_Syntax.signature in
                                   let uu___6 =
                                     FStar_Syntax_Util.apply_eff_combinators
                                       sub ed.FStar_Syntax_Syntax.combinators in
                                   let uu___7 =
                                     FStar_Compiler_List.map
                                       (fun action ->
                                          let nparam =
                                            FStar_Compiler_List.length
                                              action.FStar_Syntax_Syntax.action_params in
                                          let uu___8 =
                                            FStar_Syntax_DsEnv.qualify env2
                                              action.FStar_Syntax_Syntax.action_unqualified_name in
                                          let uu___9 =
                                            let uu___10 =
                                              sub' nparam
                                                ([],
                                                  (action.FStar_Syntax_Syntax.action_defn)) in
                                            FStar_Pervasives_Native.snd
                                              uu___10 in
                                          let uu___10 =
                                            let uu___11 =
                                              sub' nparam
                                                ([],
                                                  (action.FStar_Syntax_Syntax.action_typ)) in
                                            FStar_Pervasives_Native.snd
                                              uu___11 in
                                          {
                                            FStar_Syntax_Syntax.action_name =
                                              uu___8;
                                            FStar_Syntax_Syntax.action_unqualified_name
                                              =
                                              (action.FStar_Syntax_Syntax.action_unqualified_name);
                                            FStar_Syntax_Syntax.action_univs
                                              =
                                              (action.FStar_Syntax_Syntax.action_univs);
                                            FStar_Syntax_Syntax.action_params
                                              =
                                              (action.FStar_Syntax_Syntax.action_params);
                                            FStar_Syntax_Syntax.action_defn =
                                              uu___9;
                                            FStar_Syntax_Syntax.action_typ =
                                              uu___10
                                          }) ed.FStar_Syntax_Syntax.actions in
                                   {
                                     FStar_Syntax_Syntax.mname = mname;
                                     FStar_Syntax_Syntax.cattributes =
                                       cattributes;
                                     FStar_Syntax_Syntax.univs =
                                       (ed.FStar_Syntax_Syntax.univs);
                                     FStar_Syntax_Syntax.binders = binders1;
                                     FStar_Syntax_Syntax.signature = uu___5;
                                     FStar_Syntax_Syntax.combinators = uu___6;
                                     FStar_Syntax_Syntax.actions = uu___7;
                                     FStar_Syntax_Syntax.eff_attrs =
                                       (ed.FStar_Syntax_Syntax.eff_attrs);
                                     FStar_Syntax_Syntax.extraction_mode =
                                       (ed.FStar_Syntax_Syntax.extraction_mode)
                                   } in
                                 let se =
                                   let uu___5 =
                                     let uu___6 =
                                       trans_qual1
                                         (FStar_Pervasives_Native.Some mname) in
                                     FStar_Compiler_List.map uu___6 quals in
                                   let uu___6 =
                                     FStar_Syntax_DsEnv.opens_and_abbrevs
                                       env2 in
                                   {
                                     FStar_Syntax_Syntax.sigel =
                                       (FStar_Syntax_Syntax.Sig_new_effect
                                          ed1);
                                     FStar_Syntax_Syntax.sigrng =
                                       (d.FStar_Parser_AST.drange);
                                     FStar_Syntax_Syntax.sigquals = uu___5;
                                     FStar_Syntax_Syntax.sigmeta =
                                       FStar_Syntax_Syntax.default_sigmeta;
                                     FStar_Syntax_Syntax.sigattrs = d_attrs;
                                     FStar_Syntax_Syntax.sigopens_and_abbrevs
                                       = uu___6;
                                     FStar_Syntax_Syntax.sigopts =
                                       FStar_Pervasives_Native.None
                                   } in
                                 let monad_env = env2 in
                                 let env3 =
                                   FStar_Syntax_DsEnv.push_sigelt env0 se in
                                 let env4 =
                                   FStar_Compiler_List.fold_left
                                     (fun env5 ->
                                        fun a ->
                                          let uu___5 =
                                            FStar_Syntax_Util.action_as_lb
                                              mname a
                                              (a.FStar_Syntax_Syntax.action_defn).FStar_Syntax_Syntax.pos in
                                          FStar_Syntax_DsEnv.push_sigelt env5
                                            uu___5) env3
                                     ed1.FStar_Syntax_Syntax.actions in
                                 let env5 =
                                   if
                                     FStar_Compiler_List.contains
                                       FStar_Parser_AST.Reflectable quals
                                   then
                                     let reflect_lid =
                                       let uu___5 =
                                         FStar_Ident.id_of_text "reflect" in
                                       FStar_Syntax_DsEnv.qualify monad_env
                                         uu___5 in
                                     let quals1 =
                                       [FStar_Syntax_Syntax.Assumption;
                                       FStar_Syntax_Syntax.Reflectable mname] in
                                     let refl_decl =
                                       let uu___5 =
                                         FStar_Syntax_DsEnv.opens_and_abbrevs
                                           env4 in
                                       {
                                         FStar_Syntax_Syntax.sigel =
                                           (FStar_Syntax_Syntax.Sig_declare_typ
                                              {
                                                FStar_Syntax_Syntax.lid2 =
                                                  reflect_lid;
                                                FStar_Syntax_Syntax.us2 = [];
                                                FStar_Syntax_Syntax.t2 =
                                                  FStar_Syntax_Syntax.tun
                                              });
                                         FStar_Syntax_Syntax.sigrng =
                                           (d.FStar_Parser_AST.drange);
                                         FStar_Syntax_Syntax.sigquals =
                                           quals1;
                                         FStar_Syntax_Syntax.sigmeta =
                                           FStar_Syntax_Syntax.default_sigmeta;
                                         FStar_Syntax_Syntax.sigattrs = [];
                                         FStar_Syntax_Syntax.sigopens_and_abbrevs
                                           = uu___5;
                                         FStar_Syntax_Syntax.sigopts =
                                           FStar_Pervasives_Native.None
                                       } in
                                     FStar_Syntax_DsEnv.push_sigelt env4
                                       refl_decl
                                   else env4 in
                                 (env5, [se]))))
and (desugar_decl_maybe_fail_attr :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env ->
    fun d ->
      let no_fail_attrs ats =
        FStar_Compiler_List.filter
          (fun at ->
             let uu___ = get_fail_attr1 false at in
             FStar_Compiler_Option.isNone uu___) ats in
      let env0 =
        let uu___ = FStar_Syntax_DsEnv.snapshot env in
        FStar_Pervasives_Native.snd uu___ in
      let uu___ =
        let attrs =
          let uu___1 =
            FStar_Compiler_List.map (desugar_term env)
              d.FStar_Parser_AST.attrs in
          FStar_Syntax_Util.deduplicate_terms uu___1 in
        let uu___1 = get_fail_attr false attrs in
        match uu___1 with
        | FStar_Pervasives_Native.Some (expected_errs, lax) ->
            let d1 =
              {
                FStar_Parser_AST.d = (d.FStar_Parser_AST.d);
                FStar_Parser_AST.drange = (d.FStar_Parser_AST.drange);
                FStar_Parser_AST.quals = (d.FStar_Parser_AST.quals);
                FStar_Parser_AST.attrs = [];
                FStar_Parser_AST.interleaved =
                  (d.FStar_Parser_AST.interleaved)
              } in
            let uu___2 =
              FStar_Errors.catch_errors
                (fun uu___3 ->
                   FStar_Options.with_saved_options
                     (fun uu___4 -> desugar_decl_core env attrs d1)) in
            (match uu___2 with
             | (errs, r) ->
                 (match (errs, r) with
                  | ([], FStar_Pervasives_Native.Some (env1, ses)) ->
                      let ses1 =
                        FStar_Compiler_List.map
                          (fun se ->
                             let uu___3 = no_fail_attrs attrs in
                             {
                               FStar_Syntax_Syntax.sigel =
                                 (se.FStar_Syntax_Syntax.sigel);
                               FStar_Syntax_Syntax.sigrng =
                                 (se.FStar_Syntax_Syntax.sigrng);
                               FStar_Syntax_Syntax.sigquals =
                                 (se.FStar_Syntax_Syntax.sigquals);
                               FStar_Syntax_Syntax.sigmeta =
                                 (se.FStar_Syntax_Syntax.sigmeta);
                               FStar_Syntax_Syntax.sigattrs = uu___3;
                               FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                 (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                               FStar_Syntax_Syntax.sigopts =
                                 (se.FStar_Syntax_Syntax.sigopts)
                             }) ses in
                      let se =
                        let uu___3 =
                          FStar_Syntax_DsEnv.opens_and_abbrevs env1 in
                        {
                          FStar_Syntax_Syntax.sigel =
                            (FStar_Syntax_Syntax.Sig_fail
                               {
                                 FStar_Syntax_Syntax.errs = expected_errs;
                                 FStar_Syntax_Syntax.fail_in_lax = lax;
                                 FStar_Syntax_Syntax.ses1 = ses1
                               });
                          FStar_Syntax_Syntax.sigrng =
                            (d1.FStar_Parser_AST.drange);
                          FStar_Syntax_Syntax.sigquals = [];
                          FStar_Syntax_Syntax.sigmeta =
                            FStar_Syntax_Syntax.default_sigmeta;
                          FStar_Syntax_Syntax.sigattrs = attrs;
                          FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___3;
                          FStar_Syntax_Syntax.sigopts =
                            FStar_Pervasives_Native.None
                        } in
                      (env0, [se])
                  | (errs1, ropt) ->
                      let errnos =
                        FStar_Compiler_List.concatMap
                          (fun i ->
                             FStar_Common.list_of_option
                               i.FStar_Errors.issue_number) errs1 in
                      ((let uu___4 = FStar_Options.print_expected_failures () in
                        if uu___4
                        then
                          (FStar_Compiler_Util.print_string
                             ">> Got issues: [\n";
                           FStar_Compiler_List.iter FStar_Errors.print_issue
                             errs1;
                           FStar_Compiler_Util.print_string ">>]\n")
                        else ());
                       if expected_errs = []
                       then (env0, [])
                       else
                         (let uu___5 =
                            FStar_Errors.find_multiset_discrepancy
                              expected_errs errnos in
                          match uu___5 with
                          | FStar_Pervasives_Native.None -> (env0, [])
                          | FStar_Pervasives_Native.Some (e, n1, n2) ->
                              (FStar_Compiler_List.iter
                                 FStar_Errors.print_issue errs1;
                               (let uu___8 =
                                  let uu___9 =
                                    let uu___10 =
                                      let uu___11 =
                                        FStar_Errors_Msg.text
                                          "This top-level definition was expected to raise error codes" in
                                      let uu___12 =
                                        FStar_Class_PP.pp
                                          (FStar_Class_PP.pp_list
                                             FStar_Class_PP.pp_int)
                                          expected_errs in
                                      FStar_Pprint.prefix (Prims.of_int (2))
                                        Prims.int_one uu___11 uu___12 in
                                    let uu___11 =
                                      let uu___12 =
                                        let uu___13 =
                                          FStar_Errors_Msg.text
                                            "but it raised" in
                                        let uu___14 =
                                          FStar_Class_PP.pp
                                            (FStar_Class_PP.pp_list
                                               FStar_Class_PP.pp_int) errnos in
                                        FStar_Pprint.prefix
                                          (Prims.of_int (2)) Prims.int_one
                                          uu___13 uu___14 in
                                      let uu___13 =
                                        let uu___14 =
                                          FStar_Errors_Msg.text
                                            "(at desugaring time)" in
                                        FStar_Pprint.op_Hat_Hat uu___14
                                          FStar_Pprint.dot in
                                      FStar_Pprint.op_Hat_Hat uu___12 uu___13 in
                                    FStar_Pprint.op_Hat_Slash_Hat uu___10
                                      uu___11 in
                                  let uu___10 =
                                    let uu___11 =
                                      let uu___12 =
                                        let uu___13 =
                                          FStar_Class_Show.show
                                            (FStar_Class_Show.printableshow
                                               FStar_Class_Printable.printable_int)
                                            e in
                                        let uu___14 =
                                          FStar_Class_Show.show
                                            (FStar_Class_Show.printableshow
                                               FStar_Class_Printable.printable_int)
                                            n2 in
                                        let uu___15 =
                                          FStar_Class_Show.show
                                            (FStar_Class_Show.printableshow
                                               FStar_Class_Printable.printable_int)
                                            n1 in
                                        FStar_Compiler_Util.format3
                                          "Error #%s was raised %s times, instead of %s."
                                          uu___13 uu___14 uu___15 in
                                      FStar_Errors_Msg.text uu___12 in
                                    [uu___11] in
                                  uu___9 :: uu___10 in
                                FStar_Errors.log_issue
                                  FStar_Parser_AST.hasRange_decl d1
                                  FStar_Errors_Codes.Error_DidNotFail ()
                                  (Obj.magic
                                     FStar_Errors_Msg.is_error_message_list_doc)
                                  (Obj.magic uu___8));
                               (env0, []))))))
        | FStar_Pervasives_Native.None -> desugar_decl_core env attrs d in
      match uu___ with | (env1, sigelts) -> (env1, sigelts)
and (desugar_decl :
  env_t -> FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts)) =
  fun env ->
    fun d ->
      FStar_GenSym.reset_gensym ();
      (let uu___1 = desugar_decl_maybe_fail_attr env d in
       match uu___1 with
       | (env1, ses) ->
           let uu___2 =
             FStar_Compiler_List.map generalize_annotated_univs ses in
           (env1, uu___2))
and (desugar_decl_core :
  FStar_Syntax_DsEnv.env ->
    FStar_Syntax_Syntax.term Prims.list ->
      FStar_Parser_AST.decl -> (env_t * FStar_Syntax_Syntax.sigelts))
  =
  fun env ->
    fun d_attrs ->
      fun d ->
        let trans_qual1 = trans_qual d.FStar_Parser_AST.drange in
        match d.FStar_Parser_AST.d with
        | FStar_Parser_AST.Pragma p ->
            let p1 = trans_pragma p in
            (FStar_Syntax_Util.process_pragma p1 d.FStar_Parser_AST.drange;
             (let se =
                let uu___1 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                {
                  FStar_Syntax_Syntax.sigel =
                    (FStar_Syntax_Syntax.Sig_pragma p1);
                  FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                  FStar_Syntax_Syntax.sigquals = [];
                  FStar_Syntax_Syntax.sigmeta =
                    FStar_Syntax_Syntax.default_sigmeta;
                  FStar_Syntax_Syntax.sigattrs = d_attrs;
                  FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___1;
                  FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
                } in
              (env, [se])))
        | FStar_Parser_AST.TopLevelModule id -> (env, [])
        | FStar_Parser_AST.Open (lid, restriction) ->
            let env1 = FStar_Syntax_DsEnv.push_namespace env lid restriction in
            (env1, [])
        | FStar_Parser_AST.Friend lid ->
            let uu___ = FStar_Syntax_DsEnv.iface env in
            if uu___
            then
              FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
                FStar_Errors_Codes.Fatal_FriendInterface ()
                (Obj.magic FStar_Errors_Msg.is_error_message_string)
                (Obj.magic
                   "'friend' declarations are not allowed in interfaces")
            else
              (let uu___2 =
                 let uu___3 =
                   let uu___4 = FStar_Syntax_DsEnv.dep_graph env in
                   let uu___5 = FStar_Syntax_DsEnv.current_module env in
                   FStar_Parser_Dep.module_has_interface uu___4 uu___5 in
                 Prims.op_Negation uu___3 in
               if uu___2
               then
                 FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
                   FStar_Errors_Codes.Fatal_FriendInterface ()
                   (Obj.magic FStar_Errors_Msg.is_error_message_string)
                   (Obj.magic
                      "'friend' declarations are not allowed in modules that lack interfaces")
               else
                 (let uu___4 =
                    let uu___5 =
                      let uu___6 = FStar_Syntax_DsEnv.dep_graph env in
                      FStar_Parser_Dep.module_has_interface uu___6 lid in
                    Prims.op_Negation uu___5 in
                  if uu___4
                  then
                    FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
                      FStar_Errors_Codes.Fatal_FriendInterface ()
                      (Obj.magic FStar_Errors_Msg.is_error_message_string)
                      (Obj.magic
                         "'friend' declarations cannot refer to modules that lack interfaces")
                  else
                    (let uu___6 =
                       let uu___7 =
                         let uu___8 = FStar_Syntax_DsEnv.dep_graph env in
                         FStar_Parser_Dep.deps_has_implementation uu___8 lid in
                       Prims.op_Negation uu___7 in
                     if uu___6
                     then
                       FStar_Errors.raise_error
                         FStar_Parser_AST.hasRange_decl d
                         FStar_Errors_Codes.Fatal_FriendInterface ()
                         (Obj.magic FStar_Errors_Msg.is_error_message_string)
                         (Obj.magic
                            "'friend' module has not been loaded; recompute dependences (C-c C-r) if in interactive mode")
                     else (env, []))))
        | FStar_Parser_AST.Include (lid, restriction) ->
            let env1 = FStar_Syntax_DsEnv.push_include env lid restriction in
            (env1, [])
        | FStar_Parser_AST.ModuleAbbrev (x, l) ->
            let uu___ = FStar_Syntax_DsEnv.push_module_abbrev env x l in
            (uu___, [])
        | FStar_Parser_AST.Tycon (is_effect, typeclass, tcs) ->
            let quals = d.FStar_Parser_AST.quals in
            let quals1 =
              if is_effect
              then FStar_Parser_AST.Effect_qual :: quals
              else quals in
            let quals2 =
              if typeclass
              then
                match tcs with
                | (FStar_Parser_AST.TyconRecord uu___)::[] ->
                    FStar_Parser_AST.Noeq :: quals1
                | uu___ ->
                    FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
                      FStar_Errors_Codes.Error_BadClassDecl ()
                      (Obj.magic FStar_Errors_Msg.is_error_message_string)
                      (Obj.magic
                         "Ill-formed `class` declaration: definition must be a record type")
              else quals1 in
            let uu___ =
              let uu___1 =
                FStar_Compiler_List.map
                  (trans_qual1 FStar_Pervasives_Native.None) quals2 in
              desugar_tycon env d d_attrs uu___1 tcs in
            (match uu___ with
             | (env1, ses) ->
                 ((let uu___2 = FStar_Compiler_Effect.op_Bang dbg_attrs in
                   if uu___2
                   then
                     let uu___3 =
                       FStar_Class_Show.show FStar_Parser_AST.showable_decl d in
                     let uu___4 =
                       FStar_Class_Show.show
                         (FStar_Class_Show.show_list
                            FStar_Syntax_Print.showable_sigelt) ses in
                     FStar_Compiler_Util.print2
                       "Desugared tycon from {%s} to {%s}\n" uu___3 uu___4
                   else ());
                  (let mkclass lid =
                     let r = FStar_Ident.range_of_lid lid in
                     let body =
                       let uu___2 =
                         FStar_Syntax_Util.has_attribute d_attrs
                           FStar_Parser_Const.meta_projectors_attr in
                       if uu___2
                       then
                         let uu___3 =
                           FStar_Syntax_Syntax.tabbrev
                             FStar_Parser_Const.mk_projs_lid in
                         let uu___4 =
                           let uu___5 =
                             let uu___6 = FStar_Syntax_Util.exp_bool true in
                             FStar_Syntax_Syntax.as_arg uu___6 in
                           let uu___6 =
                             let uu___7 =
                               let uu___8 =
                                 let uu___9 = FStar_Ident.string_of_lid lid in
                                 FStar_Syntax_Util.exp_string uu___9 in
                               FStar_Syntax_Syntax.as_arg uu___8 in
                             [uu___7] in
                           uu___5 :: uu___6 in
                         FStar_Syntax_Util.mk_app uu___3 uu___4
                       else
                         (let uu___4 =
                            FStar_Syntax_Syntax.tabbrev
                              FStar_Parser_Const.mk_class_lid in
                          let uu___5 =
                            let uu___6 =
                              let uu___7 =
                                let uu___8 = FStar_Ident.string_of_lid lid in
                                FStar_Syntax_Util.exp_string uu___8 in
                              FStar_Syntax_Syntax.as_arg uu___7 in
                            [uu___6] in
                          FStar_Syntax_Util.mk_app uu___4 uu___5) in
                     let uu___2 =
                       let uu___3 =
                         let uu___4 =
                           let uu___5 = tun_r r in
                           FStar_Syntax_Syntax.new_bv
                             (FStar_Pervasives_Native.Some r) uu___5 in
                         FStar_Syntax_Syntax.mk_binder uu___4 in
                       [uu___3] in
                     FStar_Syntax_Util.abs uu___2 body
                       FStar_Pervasives_Native.None in
                   let get_meths se =
                     let rec get_fname quals3 =
                       match quals3 with
                       | (FStar_Syntax_Syntax.Projector (uu___2, id))::uu___3
                           -> FStar_Pervasives_Native.Some id
                       | uu___2::quals4 -> get_fname quals4
                       | [] -> FStar_Pervasives_Native.None in
                     let uu___2 = get_fname se.FStar_Syntax_Syntax.sigquals in
                     match uu___2 with
                     | FStar_Pervasives_Native.None -> []
                     | FStar_Pervasives_Native.Some id ->
                         let uu___3 = FStar_Syntax_DsEnv.qualify env1 id in
                         [uu___3] in
                   let formals =
                     let bndl =
                       FStar_Compiler_Util.try_find
                         (fun uu___2 ->
                            match uu___2 with
                            | {
                                FStar_Syntax_Syntax.sigel =
                                  FStar_Syntax_Syntax.Sig_bundle uu___3;
                                FStar_Syntax_Syntax.sigrng = uu___4;
                                FStar_Syntax_Syntax.sigquals = uu___5;
                                FStar_Syntax_Syntax.sigmeta = uu___6;
                                FStar_Syntax_Syntax.sigattrs = uu___7;
                                FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                  uu___8;
                                FStar_Syntax_Syntax.sigopts = uu___9;_} ->
                                true
                            | uu___3 -> false) ses in
                     match bndl with
                     | FStar_Pervasives_Native.None ->
                         FStar_Pervasives_Native.None
                     | FStar_Pervasives_Native.Some bndl1 ->
                         (match bndl1.FStar_Syntax_Syntax.sigel with
                          | FStar_Syntax_Syntax.Sig_bundle
                              { FStar_Syntax_Syntax.ses = ses1;
                                FStar_Syntax_Syntax.lids = uu___2;_}
                              ->
                              FStar_Compiler_Util.find_map ses1
                                (fun se ->
                                   match se.FStar_Syntax_Syntax.sigel with
                                   | FStar_Syntax_Syntax.Sig_datacon
                                       { FStar_Syntax_Syntax.lid1 = uu___3;
                                         FStar_Syntax_Syntax.us1 = uu___4;
                                         FStar_Syntax_Syntax.t1 = t;
                                         FStar_Syntax_Syntax.ty_lid = uu___5;
                                         FStar_Syntax_Syntax.num_ty_params =
                                           uu___6;
                                         FStar_Syntax_Syntax.mutuals1 =
                                           uu___7;
                                         FStar_Syntax_Syntax.injective_type_params1
                                           = uu___8;_}
                                       ->
                                       let uu___9 =
                                         FStar_Syntax_Util.arrow_formals t in
                                       (match uu___9 with
                                        | (formals1, uu___10) ->
                                            FStar_Pervasives_Native.Some
                                              formals1)
                                   | uu___3 -> FStar_Pervasives_Native.None)
                          | uu___2 -> FStar_Pervasives_Native.None) in
                   let rec splice_decl meths se =
                     match se.FStar_Syntax_Syntax.sigel with
                     | FStar_Syntax_Syntax.Sig_bundle
                         { FStar_Syntax_Syntax.ses = ses1;
                           FStar_Syntax_Syntax.lids = uu___2;_}
                         ->
                         FStar_Compiler_List.concatMap (splice_decl meths)
                           ses1
                     | FStar_Syntax_Syntax.Sig_inductive_typ
                         { FStar_Syntax_Syntax.lid = lid;
                           FStar_Syntax_Syntax.us = uu___2;
                           FStar_Syntax_Syntax.params = uu___3;
                           FStar_Syntax_Syntax.num_uniform_params = uu___4;
                           FStar_Syntax_Syntax.t = ty;
                           FStar_Syntax_Syntax.mutuals = uu___5;
                           FStar_Syntax_Syntax.ds = uu___6;
                           FStar_Syntax_Syntax.injective_type_params = uu___7;_}
                         ->
                         let formals1 =
                           match formals with
                           | FStar_Pervasives_Native.None -> []
                           | FStar_Pervasives_Native.Some formals2 ->
                               formals2 in
                         let has_no_method_attr meth =
                           let i = FStar_Ident.ident_of_lid meth in
                           FStar_Compiler_Util.for_some
                             (fun formal ->
                                let uu___8 =
                                  FStar_Ident.ident_equals i
                                    (formal.FStar_Syntax_Syntax.binder_bv).FStar_Syntax_Syntax.ppname in
                                if uu___8
                                then
                                  FStar_Compiler_Util.for_some
                                    (fun attr ->
                                       let uu___9 =
                                         let uu___10 =
                                           FStar_Syntax_Subst.compress attr in
                                         uu___10.FStar_Syntax_Syntax.n in
                                       match uu___9 with
                                       | FStar_Syntax_Syntax.Tm_fvar fv ->
                                           FStar_Syntax_Syntax.fv_eq_lid fv
                                             FStar_Parser_Const.no_method_lid
                                       | uu___10 -> false)
                                    formal.FStar_Syntax_Syntax.binder_attrs
                                else false) formals1 in
                         let meths1 =
                           FStar_Compiler_List.filter
                             (fun x ->
                                let uu___8 = has_no_method_attr x in
                                Prims.op_Negation uu___8) meths in
                         let is_typed = false in
                         let uu___8 =
                           let uu___9 =
                             let uu___10 =
                               let uu___11 = mkclass lid in
                               {
                                 FStar_Syntax_Syntax.is_typed = is_typed;
                                 FStar_Syntax_Syntax.lids2 = meths1;
                                 FStar_Syntax_Syntax.tac = uu___11
                               } in
                             FStar_Syntax_Syntax.Sig_splice uu___10 in
                           let uu___10 =
                             FStar_Syntax_DsEnv.opens_and_abbrevs env1 in
                           {
                             FStar_Syntax_Syntax.sigel = uu___9;
                             FStar_Syntax_Syntax.sigrng =
                               (d.FStar_Parser_AST.drange);
                             FStar_Syntax_Syntax.sigquals = [];
                             FStar_Syntax_Syntax.sigmeta =
                               FStar_Syntax_Syntax.default_sigmeta;
                             FStar_Syntax_Syntax.sigattrs = [];
                             FStar_Syntax_Syntax.sigopens_and_abbrevs =
                               uu___10;
                             FStar_Syntax_Syntax.sigopts =
                               FStar_Pervasives_Native.None
                           } in
                         [uu___8]
                     | uu___2 -> [] in
                   let uu___2 =
                     if typeclass
                     then
                       let meths =
                         FStar_Compiler_List.concatMap get_meths ses in
                       let rec add_class_attr se =
                         match se.FStar_Syntax_Syntax.sigel with
                         | FStar_Syntax_Syntax.Sig_bundle
                             { FStar_Syntax_Syntax.ses = ses1;
                               FStar_Syntax_Syntax.lids = lids;_}
                             ->
                             let ses2 =
                               FStar_Compiler_List.map add_class_attr ses1 in
                             let uu___3 =
                               let uu___4 =
                                 let uu___5 =
                                   FStar_Syntax_Syntax.fvar_with_dd
                                     FStar_Parser_Const.tcclass_lid
                                     FStar_Pervasives_Native.None in
                                 uu___5 :: (se.FStar_Syntax_Syntax.sigattrs) in
                               FStar_Syntax_Util.deduplicate_terms uu___4 in
                             {
                               FStar_Syntax_Syntax.sigel =
                                 (FStar_Syntax_Syntax.Sig_bundle
                                    {
                                      FStar_Syntax_Syntax.ses = ses2;
                                      FStar_Syntax_Syntax.lids = lids
                                    });
                               FStar_Syntax_Syntax.sigrng =
                                 (se.FStar_Syntax_Syntax.sigrng);
                               FStar_Syntax_Syntax.sigquals =
                                 (se.FStar_Syntax_Syntax.sigquals);
                               FStar_Syntax_Syntax.sigmeta =
                                 (se.FStar_Syntax_Syntax.sigmeta);
                               FStar_Syntax_Syntax.sigattrs = uu___3;
                               FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                 (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                               FStar_Syntax_Syntax.sigopts =
                                 (se.FStar_Syntax_Syntax.sigopts)
                             }
                         | FStar_Syntax_Syntax.Sig_inductive_typ uu___3 ->
                             let uu___4 =
                               let uu___5 =
                                 let uu___6 =
                                   FStar_Syntax_Syntax.fvar_with_dd
                                     FStar_Parser_Const.tcclass_lid
                                     FStar_Pervasives_Native.None in
                                 uu___6 :: (se.FStar_Syntax_Syntax.sigattrs) in
                               FStar_Syntax_Util.deduplicate_terms uu___5 in
                             {
                               FStar_Syntax_Syntax.sigel =
                                 (se.FStar_Syntax_Syntax.sigel);
                               FStar_Syntax_Syntax.sigrng =
                                 (se.FStar_Syntax_Syntax.sigrng);
                               FStar_Syntax_Syntax.sigquals =
                                 (se.FStar_Syntax_Syntax.sigquals);
                               FStar_Syntax_Syntax.sigmeta =
                                 (se.FStar_Syntax_Syntax.sigmeta);
                               FStar_Syntax_Syntax.sigattrs = uu___4;
                               FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                 (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                               FStar_Syntax_Syntax.sigopts =
                                 (se.FStar_Syntax_Syntax.sigopts)
                             }
                         | uu___3 -> se in
                       let uu___3 =
                         FStar_Compiler_List.map add_class_attr ses in
                       let uu___4 =
                         FStar_Compiler_List.concatMap (splice_decl meths)
                           ses in
                       (uu___3, uu___4)
                     else (ses, []) in
                   match uu___2 with
                   | (ses1, extra) ->
                       let env2 =
                         FStar_Compiler_List.fold_left
                           FStar_Syntax_DsEnv.push_sigelt env1 extra in
                       (env2, (FStar_Compiler_List.op_At ses1 extra)))))
        | FStar_Parser_AST.TopLevelLet (isrec, lets) ->
            let quals = d.FStar_Parser_AST.quals in
            let expand_toplevel_pattern =
              (isrec = FStar_Parser_AST.NoLetQualifier) &&
                (match lets with
                 | ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatOp uu___;
                      FStar_Parser_AST.prange = uu___1;_},
                    uu___2)::[] -> false
                 | ({ FStar_Parser_AST.pat = FStar_Parser_AST.PatVar uu___;
                      FStar_Parser_AST.prange = uu___1;_},
                    uu___2)::[] -> false
                 | ({
                      FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed
                        ({
                           FStar_Parser_AST.pat = FStar_Parser_AST.PatOp
                             uu___;
                           FStar_Parser_AST.prange = uu___1;_},
                         uu___2);
                      FStar_Parser_AST.prange = uu___3;_},
                    uu___4)::[] -> false
                 | ({
                      FStar_Parser_AST.pat = FStar_Parser_AST.PatAscribed
                        ({
                           FStar_Parser_AST.pat = FStar_Parser_AST.PatVar
                             uu___;
                           FStar_Parser_AST.prange = uu___1;_},
                         uu___2);
                      FStar_Parser_AST.prange = uu___3;_},
                    uu___4)::[] -> false
                 | (p, uu___)::[] ->
                     let uu___1 = is_app_pattern p in
                     Prims.op_Negation uu___1
                 | uu___ -> false) in
            if Prims.op_Negation expand_toplevel_pattern
            then
              let lets1 =
                FStar_Compiler_List.map
                  (fun x -> (FStar_Pervasives_Native.None, x)) lets in
              let as_inner_let =
                let uu___ =
                  let uu___1 =
                    let uu___2 =
                      FStar_Parser_AST.mk_term
                        (FStar_Parser_AST.Const FStar_Const.Const_unit)
                        d.FStar_Parser_AST.drange FStar_Parser_AST.Expr in
                    (isrec, lets1, uu___2) in
                  FStar_Parser_AST.Let uu___1 in
                FStar_Parser_AST.mk_term uu___ d.FStar_Parser_AST.drange
                  FStar_Parser_AST.Expr in
              let uu___ = desugar_term_maybe_top true env as_inner_let in
              (match uu___ with
               | (ds_lets, aq) ->
                   (check_no_aq aq;
                    (let uu___2 =
                       let uu___3 = FStar_Syntax_Subst.compress ds_lets in
                       uu___3.FStar_Syntax_Syntax.n in
                     match uu___2 with
                     | FStar_Syntax_Syntax.Tm_let
                         { FStar_Syntax_Syntax.lbs = lbs;
                           FStar_Syntax_Syntax.body1 = uu___3;_}
                         ->
                         let fvs =
                           FStar_Compiler_List.map
                             (fun lb ->
                                FStar_Compiler_Util.right
                                  lb.FStar_Syntax_Syntax.lbname)
                             (FStar_Pervasives_Native.snd lbs) in
                         let uu___4 =
                           FStar_Compiler_List.fold_right
                             (fun fv ->
                                fun uu___5 ->
                                  match uu___5 with
                                  | (qs, ats) ->
                                      let uu___6 =
                                        FStar_Syntax_DsEnv.lookup_letbinding_quals_and_attrs
                                          env
                                          (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v in
                                      (match uu___6 with
                                       | (qs', ats') ->
                                           ((FStar_Compiler_List.op_At qs' qs),
                                             (FStar_Compiler_List.op_At ats'
                                                ats)))) fvs ([], []) in
                         (match uu___4 with
                          | (val_quals, val_attrs) ->
                              let top_attrs = d_attrs in
                              let lbs1 =
                                let uu___5 = lbs in
                                match uu___5 with
                                | (isrec1, lbs0) ->
                                    let lbs01 =
                                      FStar_Compiler_List.map
                                        (fun lb ->
                                           let uu___6 =
                                             FStar_Syntax_Util.deduplicate_terms
                                               (FStar_Compiler_List.op_At
                                                  lb.FStar_Syntax_Syntax.lbattrs
                                                  (FStar_Compiler_List.op_At
                                                     val_attrs top_attrs)) in
                                           {
                                             FStar_Syntax_Syntax.lbname =
                                               (lb.FStar_Syntax_Syntax.lbname);
                                             FStar_Syntax_Syntax.lbunivs =
                                               (lb.FStar_Syntax_Syntax.lbunivs);
                                             FStar_Syntax_Syntax.lbtyp =
                                               (lb.FStar_Syntax_Syntax.lbtyp);
                                             FStar_Syntax_Syntax.lbeff =
                                               (lb.FStar_Syntax_Syntax.lbeff);
                                             FStar_Syntax_Syntax.lbdef =
                                               (lb.FStar_Syntax_Syntax.lbdef);
                                             FStar_Syntax_Syntax.lbattrs =
                                               uu___6;
                                             FStar_Syntax_Syntax.lbpos =
                                               (lb.FStar_Syntax_Syntax.lbpos)
                                           }) lbs0 in
                                    (isrec1, lbs01) in
                              let quals1 =
                                match quals with
                                | uu___5::uu___6 ->
                                    FStar_Compiler_List.map
                                      (trans_qual1
                                         FStar_Pervasives_Native.None) quals
                                | uu___5 -> val_quals in
                              let quals2 =
                                let uu___5 =
                                  FStar_Compiler_Util.for_some
                                    (fun uu___6 ->
                                       match uu___6 with
                                       | (uu___7, (uu___8, t)) ->
                                           t.FStar_Parser_AST.level =
                                             FStar_Parser_AST.Formula) lets1 in
                                if uu___5
                                then FStar_Syntax_Syntax.Logic :: quals1
                                else quals1 in
                              let names =
                                FStar_Compiler_List.map
                                  (fun fv ->
                                     (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                                  fvs in
                              let s =
                                let uu___5 =
                                  FStar_Syntax_Util.deduplicate_terms
                                    (FStar_Compiler_List.op_At val_attrs
                                       top_attrs) in
                                let uu___6 =
                                  FStar_Syntax_DsEnv.opens_and_abbrevs env in
                                {
                                  FStar_Syntax_Syntax.sigel =
                                    (FStar_Syntax_Syntax.Sig_let
                                       {
                                         FStar_Syntax_Syntax.lbs1 = lbs1;
                                         FStar_Syntax_Syntax.lids1 = names
                                       });
                                  FStar_Syntax_Syntax.sigrng =
                                    (d.FStar_Parser_AST.drange);
                                  FStar_Syntax_Syntax.sigquals = quals2;
                                  FStar_Syntax_Syntax.sigmeta =
                                    FStar_Syntax_Syntax.default_sigmeta;
                                  FStar_Syntax_Syntax.sigattrs = uu___5;
                                  FStar_Syntax_Syntax.sigopens_and_abbrevs =
                                    uu___6;
                                  FStar_Syntax_Syntax.sigopts =
                                    FStar_Pervasives_Native.None
                                } in
                              let env1 = FStar_Syntax_DsEnv.push_sigelt env s in
                              (env1, [s]))
                     | uu___3 ->
                         FStar_Compiler_Effect.failwith
                           "Desugaring a let did not produce a let")))
            else
              (let uu___1 =
                 match lets with
                 | (pat, body)::[] -> (pat, body)
                 | uu___2 ->
                     FStar_Compiler_Effect.failwith
                       "expand_toplevel_pattern should only allow single definition lets" in
               match uu___1 with
               | (pat, body) ->
                   let rec gen_fresh_toplevel_name uu___2 =
                     let nm =
                       FStar_Ident.gen FStar_Compiler_Range_Type.dummyRange in
                     let uu___3 =
                       let uu___4 =
                         let uu___5 = FStar_Ident.lid_of_ids [nm] in
                         FStar_Syntax_DsEnv.resolve_name env uu___5 in
                       FStar_Pervasives_Native.uu___is_Some uu___4 in
                     if uu___3 then gen_fresh_toplevel_name () else nm in
                   let fresh_toplevel_name = gen_fresh_toplevel_name () in
                   let fresh_pat =
                     let var_pat =
                       FStar_Parser_AST.mk_pattern
                         (FStar_Parser_AST.PatVar
                            (fresh_toplevel_name,
                              FStar_Pervasives_Native.None, []))
                         FStar_Compiler_Range_Type.dummyRange in
                     match pat.FStar_Parser_AST.pat with
                     | FStar_Parser_AST.PatAscribed (pat1, ty) ->
                         {
                           FStar_Parser_AST.pat =
                             (FStar_Parser_AST.PatAscribed (var_pat, ty));
                           FStar_Parser_AST.prange =
                             (pat1.FStar_Parser_AST.prange)
                         }
                     | uu___2 -> var_pat in
                   let main_let =
                     let quals1 =
                       if
                         FStar_Compiler_List.mem FStar_Parser_AST.Private
                           d.FStar_Parser_AST.quals
                       then d.FStar_Parser_AST.quals
                       else FStar_Parser_AST.Private ::
                         (d.FStar_Parser_AST.quals) in
                     desugar_decl env
                       {
                         FStar_Parser_AST.d =
                           (FStar_Parser_AST.TopLevelLet
                              (isrec, [(fresh_pat, body)]));
                         FStar_Parser_AST.drange =
                           (d.FStar_Parser_AST.drange);
                         FStar_Parser_AST.quals = quals1;
                         FStar_Parser_AST.attrs = (d.FStar_Parser_AST.attrs);
                         FStar_Parser_AST.interleaved =
                           (d.FStar_Parser_AST.interleaved)
                       } in
                   let main =
                     let uu___2 =
                       let uu___3 =
                         FStar_Ident.lid_of_ids [fresh_toplevel_name] in
                       FStar_Parser_AST.Var uu___3 in
                     FStar_Parser_AST.mk_term uu___2
                       pat.FStar_Parser_AST.prange FStar_Parser_AST.Expr in
                   let build_generic_projection uu___2 id_opt =
                     match uu___2 with
                     | (env1, ses) ->
                         let uu___3 =
                           match id_opt with
                           | FStar_Pervasives_Native.Some id ->
                               let lid = FStar_Ident.lid_of_ids [id] in
                               let branch =
                                 let uu___4 = FStar_Ident.range_of_lid lid in
                                 FStar_Parser_AST.mk_term
                                   (FStar_Parser_AST.Var lid) uu___4
                                   FStar_Parser_AST.Expr in
                               let bv_pat =
                                 let uu___4 = FStar_Ident.range_of_id id in
                                 FStar_Parser_AST.mk_pattern
                                   (FStar_Parser_AST.PatVar
                                      (id, FStar_Pervasives_Native.None, []))
                                   uu___4 in
                               (bv_pat, branch)
                           | FStar_Pervasives_Native.None ->
                               let id = gen_fresh_toplevel_name () in
                               let branch =
                                 FStar_Parser_AST.mk_term
                                   (FStar_Parser_AST.Const
                                      FStar_Const.Const_unit)
                                   FStar_Compiler_Range_Type.dummyRange
                                   FStar_Parser_AST.Expr in
                               let bv_pat =
                                 let uu___4 = FStar_Ident.range_of_id id in
                                 FStar_Parser_AST.mk_pattern
                                   (FStar_Parser_AST.PatVar
                                      (id, FStar_Pervasives_Native.None, []))
                                   uu___4 in
                               let bv_pat1 =
                                 let uu___4 =
                                   let uu___5 =
                                     let uu___6 =
                                       let uu___7 =
                                         let uu___8 =
                                           FStar_Ident.range_of_id id in
                                         unit_ty uu___8 in
                                       (uu___7, FStar_Pervasives_Native.None) in
                                     (bv_pat, uu___6) in
                                   FStar_Parser_AST.PatAscribed uu___5 in
                                 let uu___5 = FStar_Ident.range_of_id id in
                                 FStar_Parser_AST.mk_pattern uu___4 uu___5 in
                               (bv_pat1, branch) in
                         (match uu___3 with
                          | (bv_pat, branch) ->
                              let body1 =
                                FStar_Parser_AST.mk_term
                                  (FStar_Parser_AST.Match
                                     (main, FStar_Pervasives_Native.None,
                                       FStar_Pervasives_Native.None,
                                       [(pat, FStar_Pervasives_Native.None,
                                          branch)]))
                                  main.FStar_Parser_AST.range
                                  FStar_Parser_AST.Expr in
                              let id_decl =
                                FStar_Parser_AST.mk_decl
                                  (FStar_Parser_AST.TopLevelLet
                                     (FStar_Parser_AST.NoLetQualifier,
                                       [(bv_pat, body1)]))
                                  FStar_Compiler_Range_Type.dummyRange [] in
                              let id_decl1 =
                                {
                                  FStar_Parser_AST.d =
                                    (id_decl.FStar_Parser_AST.d);
                                  FStar_Parser_AST.drange =
                                    (id_decl.FStar_Parser_AST.drange);
                                  FStar_Parser_AST.quals =
                                    (d.FStar_Parser_AST.quals);
                                  FStar_Parser_AST.attrs =
                                    (id_decl.FStar_Parser_AST.attrs);
                                  FStar_Parser_AST.interleaved =
                                    (id_decl.FStar_Parser_AST.interleaved)
                                } in
                              let uu___4 = desugar_decl env1 id_decl1 in
                              (match uu___4 with
                               | (env2, ses') ->
                                   (env2,
                                     (FStar_Compiler_List.op_At ses ses')))) in
                   let build_projection uu___2 id =
                     match uu___2 with
                     | (env1, ses) ->
                         build_generic_projection (env1, ses)
                           (FStar_Pervasives_Native.Some id) in
                   let build_coverage_check uu___2 =
                     match uu___2 with
                     | (env1, ses) ->
                         build_generic_projection (env1, ses)
                           FStar_Pervasives_Native.None in
                   let bvs =
                     let uu___2 = gather_pattern_bound_vars pat in
                     FStar_Class_Setlike.elems ()
                       (Obj.magic
                          (FStar_Compiler_FlatSet.setlike_flat_set
                             FStar_Syntax_Syntax.ord_ident))
                       (Obj.magic uu___2) in
                   let uu___2 =
                     (FStar_Compiler_List.isEmpty bvs) &&
                       (let uu___3 = is_var_pattern pat in
                        Prims.op_Negation uu___3) in
                   if uu___2
                   then build_coverage_check main_let
                   else
                     FStar_Compiler_List.fold_left build_projection main_let
                       bvs)
        | FStar_Parser_AST.Assume (id, t) ->
            let f = desugar_formula env t in
            let lid = FStar_Syntax_DsEnv.qualify env id in
            let uu___ =
              let uu___1 =
                let uu___2 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                {
                  FStar_Syntax_Syntax.sigel =
                    (FStar_Syntax_Syntax.Sig_assume
                       {
                         FStar_Syntax_Syntax.lid3 = lid;
                         FStar_Syntax_Syntax.us3 = [];
                         FStar_Syntax_Syntax.phi1 = f
                       });
                  FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                  FStar_Syntax_Syntax.sigquals =
                    [FStar_Syntax_Syntax.Assumption];
                  FStar_Syntax_Syntax.sigmeta =
                    FStar_Syntax_Syntax.default_sigmeta;
                  FStar_Syntax_Syntax.sigattrs = d_attrs;
                  FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                  FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
                } in
              [uu___1] in
            (env, uu___)
        | FStar_Parser_AST.Val (id, t) ->
            let quals = d.FStar_Parser_AST.quals in
            let t1 = let uu___ = close_fun env t in desugar_term env uu___ in
            let quals1 =
              let uu___ =
                (FStar_Syntax_DsEnv.iface env) &&
                  (FStar_Syntax_DsEnv.admitted_iface env) in
              if uu___ then FStar_Parser_AST.Assumption :: quals else quals in
            let lid = FStar_Syntax_DsEnv.qualify env id in
            let se =
              let uu___ =
                FStar_Compiler_List.map
                  (trans_qual1 FStar_Pervasives_Native.None) quals1 in
              let uu___1 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_declare_typ
                     {
                       FStar_Syntax_Syntax.lid2 = lid;
                       FStar_Syntax_Syntax.us2 = [];
                       FStar_Syntax_Syntax.t2 = t1
                     });
                FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                FStar_Syntax_Syntax.sigquals = uu___;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = d_attrs;
                FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___1;
                FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
              } in
            let env1 = FStar_Syntax_DsEnv.push_sigelt env se in (env1, [se])
        | FStar_Parser_AST.Exception (id, t_opt) ->
            let t =
              match t_opt with
              | FStar_Pervasives_Native.None ->
                  FStar_Syntax_DsEnv.fail_or env
                    (FStar_Syntax_DsEnv.try_lookup_lid env)
                    FStar_Parser_Const.exn_lid
              | FStar_Pervasives_Native.Some term ->
                  let t1 = desugar_term env term in
                  let uu___ =
                    let uu___1 = FStar_Syntax_Syntax.null_binder t1 in
                    [uu___1] in
                  let uu___1 =
                    let uu___2 =
                      FStar_Syntax_DsEnv.fail_or env
                        (FStar_Syntax_DsEnv.try_lookup_lid env)
                        FStar_Parser_Const.exn_lid in
                    FStar_Syntax_Syntax.mk_Total uu___2 in
                  FStar_Syntax_Util.arrow uu___ uu___1 in
            let l = FStar_Syntax_DsEnv.qualify env id in
            let qual = [FStar_Syntax_Syntax.ExceptionConstructor] in
            let top_attrs = d_attrs in
            let se =
              let uu___ = FStar_Syntax_DsEnv.opens_and_abbrevs env in
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_datacon
                     {
                       FStar_Syntax_Syntax.lid1 = l;
                       FStar_Syntax_Syntax.us1 = [];
                       FStar_Syntax_Syntax.t1 = t;
                       FStar_Syntax_Syntax.ty_lid =
                         FStar_Parser_Const.exn_lid;
                       FStar_Syntax_Syntax.num_ty_params = Prims.int_zero;
                       FStar_Syntax_Syntax.mutuals1 =
                         [FStar_Parser_Const.exn_lid];
                       FStar_Syntax_Syntax.injective_type_params1 = false
                     });
                FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                FStar_Syntax_Syntax.sigquals = qual;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = top_attrs;
                FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___;
                FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
              } in
            let se' =
              let uu___ = FStar_Syntax_DsEnv.opens_and_abbrevs env in
              {
                FStar_Syntax_Syntax.sigel =
                  (FStar_Syntax_Syntax.Sig_bundle
                     {
                       FStar_Syntax_Syntax.ses = [se];
                       FStar_Syntax_Syntax.lids = [l]
                     });
                FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                FStar_Syntax_Syntax.sigquals = qual;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = top_attrs;
                FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___;
                FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
              } in
            let env1 = FStar_Syntax_DsEnv.push_sigelt env se' in
            let data_ops = mk_data_projector_names [] env1 se in
            let discs = mk_data_discriminators [] env1 [l] top_attrs in
            let env2 =
              FStar_Compiler_List.fold_left FStar_Syntax_DsEnv.push_sigelt
                env1 (FStar_Compiler_List.op_At discs data_ops) in
            (env2, (FStar_Compiler_List.op_At (se' :: discs) data_ops))
        | FStar_Parser_AST.NewEffect (FStar_Parser_AST.RedefineEffect
            (eff_name, eff_binders, defn)) ->
            let quals = d.FStar_Parser_AST.quals in
            desugar_redefine_effect env d d_attrs trans_qual1 quals eff_name
              eff_binders defn
        | FStar_Parser_AST.NewEffect (FStar_Parser_AST.DefineEffect
            (eff_name, eff_binders, eff_typ, eff_decls)) ->
            let quals = d.FStar_Parser_AST.quals in
            desugar_effect env d d_attrs quals false eff_name eff_binders
              eff_typ eff_decls
        | FStar_Parser_AST.LayeredEffect (FStar_Parser_AST.DefineEffect
            (eff_name, eff_binders, eff_typ, eff_decls)) ->
            let quals = d.FStar_Parser_AST.quals in
            desugar_effect env d d_attrs quals true eff_name eff_binders
              eff_typ eff_decls
        | FStar_Parser_AST.LayeredEffect (FStar_Parser_AST.RedefineEffect
            uu___) ->
            FStar_Compiler_Effect.failwith
              "Impossible: LayeredEffect (RedefineEffect _) (should not be parseable)"
        | FStar_Parser_AST.SubEffect l ->
            let src_ed =
              lookup_effect_lid env l.FStar_Parser_AST.msource
                d.FStar_Parser_AST.drange in
            let dst_ed =
              lookup_effect_lid env l.FStar_Parser_AST.mdest
                d.FStar_Parser_AST.drange in
            let top_attrs = d_attrs in
            let uu___ =
              let uu___1 =
                (FStar_Syntax_Util.is_layered src_ed) ||
                  (FStar_Syntax_Util.is_layered dst_ed) in
              Prims.op_Negation uu___1 in
            if uu___
            then
              let uu___1 =
                match l.FStar_Parser_AST.lift_op with
                | FStar_Parser_AST.NonReifiableLift t ->
                    let uu___2 =
                      let uu___3 =
                        let uu___4 = desugar_term env t in ([], uu___4) in
                      FStar_Pervasives_Native.Some uu___3 in
                    (uu___2, FStar_Pervasives_Native.None)
                | FStar_Parser_AST.ReifiableLift (wp, t) ->
                    let uu___2 =
                      let uu___3 =
                        let uu___4 = desugar_term env wp in ([], uu___4) in
                      FStar_Pervasives_Native.Some uu___3 in
                    let uu___3 =
                      let uu___4 =
                        let uu___5 = desugar_term env t in ([], uu___5) in
                      FStar_Pervasives_Native.Some uu___4 in
                    (uu___2, uu___3)
                | FStar_Parser_AST.LiftForFree t ->
                    let uu___2 =
                      let uu___3 =
                        let uu___4 = desugar_term env t in ([], uu___4) in
                      FStar_Pervasives_Native.Some uu___3 in
                    (FStar_Pervasives_Native.None, uu___2) in
              (match uu___1 with
               | (lift_wp, lift) ->
                   let se =
                     let uu___2 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                     {
                       FStar_Syntax_Syntax.sigel =
                         (FStar_Syntax_Syntax.Sig_sub_effect
                            {
                              FStar_Syntax_Syntax.source =
                                (src_ed.FStar_Syntax_Syntax.mname);
                              FStar_Syntax_Syntax.target =
                                (dst_ed.FStar_Syntax_Syntax.mname);
                              FStar_Syntax_Syntax.lift_wp = lift_wp;
                              FStar_Syntax_Syntax.lift = lift;
                              FStar_Syntax_Syntax.kind =
                                FStar_Pervasives_Native.None
                            });
                       FStar_Syntax_Syntax.sigrng =
                         (d.FStar_Parser_AST.drange);
                       FStar_Syntax_Syntax.sigquals = [];
                       FStar_Syntax_Syntax.sigmeta =
                         FStar_Syntax_Syntax.default_sigmeta;
                       FStar_Syntax_Syntax.sigattrs = top_attrs;
                       FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                       FStar_Syntax_Syntax.sigopts =
                         FStar_Pervasives_Native.None
                     } in
                   (env, [se]))
            else
              (match l.FStar_Parser_AST.lift_op with
               | FStar_Parser_AST.NonReifiableLift t ->
                   let sub_eff =
                     let uu___2 =
                       let uu___3 =
                         let uu___4 = desugar_term env t in ([], uu___4) in
                       FStar_Pervasives_Native.Some uu___3 in
                     {
                       FStar_Syntax_Syntax.source =
                         (src_ed.FStar_Syntax_Syntax.mname);
                       FStar_Syntax_Syntax.target =
                         (dst_ed.FStar_Syntax_Syntax.mname);
                       FStar_Syntax_Syntax.lift_wp =
                         FStar_Pervasives_Native.None;
                       FStar_Syntax_Syntax.lift = uu___2;
                       FStar_Syntax_Syntax.kind =
                         FStar_Pervasives_Native.None
                     } in
                   let uu___2 =
                     let uu___3 =
                       let uu___4 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                       {
                         FStar_Syntax_Syntax.sigel =
                           (FStar_Syntax_Syntax.Sig_sub_effect sub_eff);
                         FStar_Syntax_Syntax.sigrng =
                           (d.FStar_Parser_AST.drange);
                         FStar_Syntax_Syntax.sigquals = [];
                         FStar_Syntax_Syntax.sigmeta =
                           FStar_Syntax_Syntax.default_sigmeta;
                         FStar_Syntax_Syntax.sigattrs = top_attrs;
                         FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___4;
                         FStar_Syntax_Syntax.sigopts =
                           FStar_Pervasives_Native.None
                       } in
                     [uu___3] in
                   (env, uu___2)
               | uu___2 ->
                   FStar_Compiler_Effect.failwith
                     "Impossible! unexpected lift_op for lift to a layered effect")
        | FStar_Parser_AST.Polymonadic_bind (m_eff, n_eff, p_eff, bind) ->
            let m = lookup_effect_lid env m_eff d.FStar_Parser_AST.drange in
            let n = lookup_effect_lid env n_eff d.FStar_Parser_AST.drange in
            let p = lookup_effect_lid env p_eff d.FStar_Parser_AST.drange in
            let top_attrs = d_attrs in
            let uu___ =
              let uu___1 =
                let uu___2 =
                  let uu___3 =
                    let uu___4 =
                      let uu___5 = desugar_term env bind in ([], uu___5) in
                    {
                      FStar_Syntax_Syntax.m_lid =
                        (m.FStar_Syntax_Syntax.mname);
                      FStar_Syntax_Syntax.n_lid =
                        (n.FStar_Syntax_Syntax.mname);
                      FStar_Syntax_Syntax.p_lid =
                        (p.FStar_Syntax_Syntax.mname);
                      FStar_Syntax_Syntax.tm3 = uu___4;
                      FStar_Syntax_Syntax.typ = ([], FStar_Syntax_Syntax.tun);
                      FStar_Syntax_Syntax.kind1 =
                        FStar_Pervasives_Native.None
                    } in
                  FStar_Syntax_Syntax.Sig_polymonadic_bind uu___3 in
                let uu___3 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                {
                  FStar_Syntax_Syntax.sigel = uu___2;
                  FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                  FStar_Syntax_Syntax.sigquals = [];
                  FStar_Syntax_Syntax.sigmeta =
                    FStar_Syntax_Syntax.default_sigmeta;
                  FStar_Syntax_Syntax.sigattrs = top_attrs;
                  FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___3;
                  FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
                } in
              [uu___1] in
            (env, uu___)
        | FStar_Parser_AST.Polymonadic_subcomp (m_eff, n_eff, subcomp) ->
            let m = lookup_effect_lid env m_eff d.FStar_Parser_AST.drange in
            let n = lookup_effect_lid env n_eff d.FStar_Parser_AST.drange in
            let top_attrs = d_attrs in
            let uu___ =
              let uu___1 =
                let uu___2 =
                  let uu___3 =
                    let uu___4 =
                      let uu___5 = desugar_term env subcomp in ([], uu___5) in
                    {
                      FStar_Syntax_Syntax.m_lid1 =
                        (m.FStar_Syntax_Syntax.mname);
                      FStar_Syntax_Syntax.n_lid1 =
                        (n.FStar_Syntax_Syntax.mname);
                      FStar_Syntax_Syntax.tm4 = uu___4;
                      FStar_Syntax_Syntax.typ1 =
                        ([], FStar_Syntax_Syntax.tun);
                      FStar_Syntax_Syntax.kind2 =
                        FStar_Pervasives_Native.None
                    } in
                  FStar_Syntax_Syntax.Sig_polymonadic_subcomp uu___3 in
                let uu___3 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                {
                  FStar_Syntax_Syntax.sigel = uu___2;
                  FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                  FStar_Syntax_Syntax.sigquals = [];
                  FStar_Syntax_Syntax.sigmeta =
                    FStar_Syntax_Syntax.default_sigmeta;
                  FStar_Syntax_Syntax.sigattrs = top_attrs;
                  FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___3;
                  FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
                } in
              [uu___1] in
            (env, uu___)
        | FStar_Parser_AST.Splice (is_typed, ids, t) ->
            let ids1 = if d.FStar_Parser_AST.interleaved then [] else ids in
            let t1 = desugar_term env t in
            let top_attrs = d_attrs in
            let se =
              let uu___ =
                let uu___1 =
                  let uu___2 =
                    FStar_Compiler_List.map (FStar_Syntax_DsEnv.qualify env)
                      ids1 in
                  {
                    FStar_Syntax_Syntax.is_typed = is_typed;
                    FStar_Syntax_Syntax.lids2 = uu___2;
                    FStar_Syntax_Syntax.tac = t1
                  } in
                FStar_Syntax_Syntax.Sig_splice uu___1 in
              let uu___1 =
                FStar_Compiler_List.map
                  (trans_qual1 FStar_Pervasives_Native.None)
                  d.FStar_Parser_AST.quals in
              let uu___2 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
              {
                FStar_Syntax_Syntax.sigel = uu___;
                FStar_Syntax_Syntax.sigrng = (d.FStar_Parser_AST.drange);
                FStar_Syntax_Syntax.sigquals = uu___1;
                FStar_Syntax_Syntax.sigmeta =
                  FStar_Syntax_Syntax.default_sigmeta;
                FStar_Syntax_Syntax.sigattrs = top_attrs;
                FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                FStar_Syntax_Syntax.sigopts = FStar_Pervasives_Native.None
              } in
            let env1 = FStar_Syntax_DsEnv.push_sigelt env se in (env1, [se])
        | FStar_Parser_AST.UseLangDecls uu___ -> (env, [])
        | FStar_Parser_AST.Unparseable ->
            FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
              FStar_Errors_Codes.Fatal_SyntaxError ()
              (Obj.magic FStar_Errors_Msg.is_error_message_string)
              (Obj.magic "Syntax error")
        | FStar_Parser_AST.DeclSyntaxExtension
            (extension_name, code, uu___, range) ->
            let extension_parser =
              FStar_Parser_AST_Util.lookup_extension_parser extension_name in
            (match extension_parser with
             | FStar_Pervasives_Native.None ->
                 let uu___1 =
                   FStar_Compiler_Util.format1 "Unknown syntax extension %s"
                     extension_name in
                 FStar_Errors.raise_error FStar_Class_HasRange.hasRange_range
                   range FStar_Errors_Codes.Fatal_SyntaxError ()
                   (Obj.magic FStar_Errors_Msg.is_error_message_string)
                   (Obj.magic uu___1)
             | FStar_Pervasives_Native.Some parser ->
                 let opens =
                   let uu___1 =
                     FStar_Syntax_DsEnv.open_modules_and_namespaces env in
                   let uu___2 = FStar_Syntax_DsEnv.module_abbrevs env in
                   {
                     FStar_Parser_AST_Util.open_namespaces = uu___1;
                     FStar_Parser_AST_Util.module_abbreviations = uu___2
                   } in
                 let uu___1 =
                   parser.FStar_Parser_AST_Util.parse_decl opens code range in
                 (match uu___1 with
                  | FStar_Pervasives.Inl error ->
                      FStar_Errors.raise_error
                        FStar_Class_HasRange.hasRange_range
                        error.FStar_Parser_AST_Util.range
                        FStar_Errors_Codes.Fatal_SyntaxError ()
                        (Obj.magic FStar_Errors_Msg.is_error_message_string)
                        (Obj.magic error.FStar_Parser_AST_Util.message)
                  | FStar_Pervasives.Inr d' ->
                      let quals =
                        FStar_Compiler_List.op_At d'.FStar_Parser_AST.quals
                          d.FStar_Parser_AST.quals in
                      let attrs =
                        FStar_Compiler_List.op_At d'.FStar_Parser_AST.attrs
                          d.FStar_Parser_AST.attrs in
                      desugar_decl_maybe_fail_attr env
                        {
                          FStar_Parser_AST.d = (d'.FStar_Parser_AST.d);
                          FStar_Parser_AST.drange =
                            (d.FStar_Parser_AST.drange);
                          FStar_Parser_AST.quals = quals;
                          FStar_Parser_AST.attrs = attrs;
                          FStar_Parser_AST.interleaved =
                            (d.FStar_Parser_AST.interleaved)
                        }))
        | FStar_Parser_AST.DeclToBeDesugared tbs ->
            let uu___ =
              lookup_extension_tosyntax tbs.FStar_Parser_AST.lang_name in
            (match uu___ with
             | FStar_Pervasives_Native.None ->
                 let uu___1 =
                   FStar_Compiler_Util.format1
                     "Could not find desugaring callback for extension %s"
                     tbs.FStar_Parser_AST.lang_name in
                 FStar_Errors.raise_error FStar_Parser_AST.hasRange_decl d
                   FStar_Errors_Codes.Fatal_SyntaxError ()
                   (Obj.magic FStar_Errors_Msg.is_error_message_string)
                   (Obj.magic uu___1)
             | FStar_Pervasives_Native.Some desugar ->
                 let mk_sig sigel =
                   let top_attrs = d_attrs in
                   let sigel1 =
                     if d.FStar_Parser_AST.interleaved
                     then
                       match sigel with
                       | FStar_Syntax_Syntax.Sig_splice s ->
                           FStar_Syntax_Syntax.Sig_splice
                             {
                               FStar_Syntax_Syntax.is_typed =
                                 (s.FStar_Syntax_Syntax.is_typed);
                               FStar_Syntax_Syntax.lids2 = [];
                               FStar_Syntax_Syntax.tac =
                                 (s.FStar_Syntax_Syntax.tac)
                             }
                       | uu___1 -> sigel
                     else sigel in
                   let se =
                     let uu___1 =
                       FStar_Compiler_List.map
                         (trans_qual1 FStar_Pervasives_Native.None)
                         d.FStar_Parser_AST.quals in
                     let uu___2 = FStar_Syntax_DsEnv.opens_and_abbrevs env in
                     {
                       FStar_Syntax_Syntax.sigel = sigel1;
                       FStar_Syntax_Syntax.sigrng =
                         (d.FStar_Parser_AST.drange);
                       FStar_Syntax_Syntax.sigquals = uu___1;
                       FStar_Syntax_Syntax.sigmeta =
                         FStar_Syntax_Syntax.default_sigmeta;
                       FStar_Syntax_Syntax.sigattrs = top_attrs;
                       FStar_Syntax_Syntax.sigopens_and_abbrevs = uu___2;
                       FStar_Syntax_Syntax.sigopts =
                         FStar_Pervasives_Native.None
                     } in
                   se in
                 let lids =
                   FStar_Compiler_List.map (FStar_Syntax_DsEnv.qualify env)
                     tbs.FStar_Parser_AST.idents in
                 let sigelts' =
                   desugar env tbs.FStar_Parser_AST.blob lids
                     d.FStar_Parser_AST.drange in
                 let sigelts = FStar_Compiler_List.map mk_sig sigelts' in
                 let env1 =
                   FStar_Compiler_List.fold_left
                     FStar_Syntax_DsEnv.push_sigelt env sigelts in
                 (env1, sigelts))
let (desugar_decls :
  env_t ->
    FStar_Parser_AST.decl Prims.list ->
      (env_t * FStar_Syntax_Syntax.sigelt Prims.list))
  =
  fun env ->
    fun decls ->
      let uu___ =
        FStar_Compiler_List.fold_left
          (fun uu___1 ->
             fun d ->
               match uu___1 with
               | (env1, sigelts) ->
                   let uu___2 = desugar_decl env1 d in
                   (match uu___2 with
                    | (env2, se) ->
                        (env2, (FStar_Compiler_List.op_At sigelts se))))
          (env, []) decls in
      match uu___ with | (env1, sigelts) -> (env1, sigelts)
let (open_prims_all :
  (FStar_Parser_AST.decoration Prims.list -> FStar_Parser_AST.decl)
    Prims.list)
  =
  [FStar_Parser_AST.mk_decl
     (FStar_Parser_AST.Open
        (FStar_Parser_Const.prims_lid, FStar_Syntax_Syntax.Unrestricted))
     FStar_Compiler_Range_Type.dummyRange;
  FStar_Parser_AST.mk_decl
    (FStar_Parser_AST.Open
       (FStar_Parser_Const.all_lid, FStar_Syntax_Syntax.Unrestricted))
    FStar_Compiler_Range_Type.dummyRange]
let (desugar_modul_common :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    FStar_Syntax_DsEnv.env ->
      FStar_Parser_AST.modul ->
        (env_t * FStar_Syntax_Syntax.modul * Prims.bool))
  =
  fun curmod ->
    fun env ->
      fun m ->
        let env1 =
          match (curmod, m) with
          | (FStar_Pervasives_Native.None, uu___) -> env
          | (FStar_Pervasives_Native.Some
             { FStar_Syntax_Syntax.name = prev_lid;
               FStar_Syntax_Syntax.declarations = uu___;
               FStar_Syntax_Syntax.is_interface = uu___1;_},
             FStar_Parser_AST.Module (current_lid, uu___2)) when
              (FStar_Ident.lid_equals prev_lid current_lid) &&
                (FStar_Options.interactive ())
              -> env
          | (FStar_Pervasives_Native.Some prev_mod, uu___) ->
              let uu___1 =
                FStar_Syntax_DsEnv.finish_module_or_interface env prev_mod in
              FStar_Pervasives_Native.fst uu___1 in
        let uu___ =
          match m with
          | FStar_Parser_AST.Interface (mname, decls, admitted) ->
              let uu___1 =
                FStar_Syntax_DsEnv.prepare_module_or_interface true admitted
                  env1 mname FStar_Syntax_DsEnv.default_mii in
              (uu___1, mname, decls, true)
          | FStar_Parser_AST.Module (mname, decls) ->
              let uu___1 =
                FStar_Syntax_DsEnv.prepare_module_or_interface false false
                  env1 mname FStar_Syntax_DsEnv.default_mii in
              (uu___1, mname, decls, false) in
        match uu___ with
        | ((env2, pop_when_done), mname, decls, intf) ->
            let uu___1 = desugar_decls env2 decls in
            (match uu___1 with
             | (env3, sigelts) ->
                 let modul =
                   {
                     FStar_Syntax_Syntax.name = mname;
                     FStar_Syntax_Syntax.declarations = sigelts;
                     FStar_Syntax_Syntax.is_interface = intf
                   } in
                 (env3, modul, pop_when_done))
let (as_interface : FStar_Parser_AST.modul -> FStar_Parser_AST.modul) =
  fun m ->
    match m with
    | FStar_Parser_AST.Module (mname, decls) ->
        FStar_Parser_AST.Interface (mname, decls, true)
    | i -> i
let (desugar_partial_modul :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    env_t -> FStar_Parser_AST.modul -> (env_t * FStar_Syntax_Syntax.modul))
  =
  fun curmod ->
    fun env ->
      fun m ->
        let m1 =
          let uu___ =
            (FStar_Options.interactive ()) &&
              (let uu___1 =
                 let uu___2 =
                   let uu___3 = FStar_Options.file_list () in
                   FStar_Compiler_List.hd uu___3 in
                 FStar_Compiler_Util.get_file_extension uu___2 in
               FStar_Compiler_List.mem uu___1 ["fsti"; "fsi"]) in
          if uu___ then as_interface m else m in
        let uu___ = desugar_modul_common curmod env m1 in
        match uu___ with
        | (env1, modul, pop_when_done) ->
            if pop_when_done
            then let uu___1 = FStar_Syntax_DsEnv.pop () in (uu___1, modul)
            else (env1, modul)
let (desugar_modul :
  FStar_Syntax_DsEnv.env ->
    FStar_Parser_AST.modul -> (env_t * FStar_Syntax_Syntax.modul))
  =
  fun env ->
    fun m ->
      let uu___ =
        let uu___1 =
          let uu___2 = FStar_Parser_AST.lid_of_modul m in
          FStar_Class_Show.show FStar_Ident.showable_lident uu___2 in
        Prims.strcat "While desugaring module " uu___1 in
      FStar_Errors.with_ctx uu___
        (fun uu___1 ->
           let uu___2 =
             desugar_modul_common FStar_Pervasives_Native.None env m in
           match uu___2 with
           | (env1, modul, pop_when_done) ->
               let uu___3 =
                 FStar_Syntax_DsEnv.finish_module_or_interface env1 modul in
               (match uu___3 with
                | (env2, modul1) ->
                    ((let uu___5 =
                        let uu___6 =
                          FStar_Ident.string_of_lid
                            modul1.FStar_Syntax_Syntax.name in
                        FStar_Options.dump_module uu___6 in
                      if uu___5
                      then
                        let uu___6 =
                          FStar_Class_Show.show
                            FStar_Syntax_Print.showable_modul modul1 in
                        FStar_Compiler_Util.print1
                          "Module after desugaring:\n%s\n" uu___6
                      else ());
                     (let uu___5 =
                        if pop_when_done
                        then
                          FStar_Syntax_DsEnv.export_interface
                            modul1.FStar_Syntax_Syntax.name env2
                        else env2 in
                      (uu___5, modul1)))))
let with_options : 'a . (unit -> 'a) -> 'a =
  fun f ->
    let uu___ =
      FStar_Options.with_saved_options
        (fun uu___1 ->
           let r = f () in let light = FStar_Options.ml_ish () in (light, r)) in
    match uu___ with
    | (light, r) -> (if light then FStar_Options.set_ml_ish () else (); r)
let (ast_modul_to_modul :
  FStar_Parser_AST.modul ->
    FStar_Syntax_Syntax.modul FStar_Syntax_DsEnv.withenv)
  =
  fun modul ->
    fun env ->
      with_options
        (fun uu___ ->
           let uu___1 = desugar_modul env modul in
           match uu___1 with | (e, m) -> (m, e))
let (decls_to_sigelts :
  FStar_Parser_AST.decl Prims.list ->
    FStar_Syntax_Syntax.sigelts FStar_Syntax_DsEnv.withenv)
  =
  fun decls ->
    fun env ->
      with_options
        (fun uu___ ->
           let uu___1 = desugar_decls env decls in
           match uu___1 with | (env1, sigelts) -> (sigelts, env1))
let (partial_ast_modul_to_modul :
  FStar_Syntax_Syntax.modul FStar_Pervasives_Native.option ->
    FStar_Parser_AST.modul ->
      FStar_Syntax_Syntax.modul FStar_Syntax_DsEnv.withenv)
  =
  fun modul ->
    fun a_modul ->
      fun env ->
        with_options
          (fun uu___ ->
             let uu___1 = desugar_partial_modul modul env a_modul in
             match uu___1 with | (env1, modul1) -> (modul1, env1))
let (add_modul_to_env_core :
  Prims.bool ->
    FStar_Syntax_Syntax.modul ->
      FStar_Syntax_DsEnv.module_inclusion_info ->
        (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
          unit FStar_Syntax_DsEnv.withenv)
  =
  fun finish ->
    fun m ->
      fun mii ->
        fun erase_univs ->
          fun en ->
            let erase_univs_ed ed =
              let erase_binders bs =
                match bs with
                | [] -> []
                | uu___ ->
                    let t =
                      let uu___1 =
                        FStar_Syntax_Syntax.mk
                          (FStar_Syntax_Syntax.Tm_abs
                             {
                               FStar_Syntax_Syntax.bs = bs;
                               FStar_Syntax_Syntax.body =
                                 FStar_Syntax_Syntax.t_unit;
                               FStar_Syntax_Syntax.rc_opt =
                                 FStar_Pervasives_Native.None
                             }) FStar_Compiler_Range_Type.dummyRange in
                      erase_univs uu___1 in
                    let uu___1 =
                      let uu___2 = FStar_Syntax_Subst.compress t in
                      uu___2.FStar_Syntax_Syntax.n in
                    (match uu___1 with
                     | FStar_Syntax_Syntax.Tm_abs
                         { FStar_Syntax_Syntax.bs = bs1;
                           FStar_Syntax_Syntax.body = uu___2;
                           FStar_Syntax_Syntax.rc_opt = uu___3;_}
                         -> bs1
                     | uu___2 -> FStar_Compiler_Effect.failwith "Impossible") in
              let uu___ =
                let uu___1 = erase_binders ed.FStar_Syntax_Syntax.binders in
                FStar_Syntax_Subst.open_term' uu___1
                  FStar_Syntax_Syntax.t_unit in
              match uu___ with
              | (binders, uu___1, binders_opening) ->
                  let erase_term t =
                    let uu___2 =
                      let uu___3 = FStar_Syntax_Subst.subst binders_opening t in
                      erase_univs uu___3 in
                    FStar_Syntax_Subst.close binders uu___2 in
                  let erase_tscheme uu___2 =
                    match uu___2 with
                    | (us, t) ->
                        let t1 =
                          let uu___3 =
                            FStar_Syntax_Subst.shift_subst
                              (FStar_Compiler_List.length us) binders_opening in
                          FStar_Syntax_Subst.subst uu___3 t in
                        let uu___3 =
                          let uu___4 = erase_univs t1 in
                          FStar_Syntax_Subst.close binders uu___4 in
                        ([], uu___3) in
                  let erase_action action =
                    let opening =
                      FStar_Syntax_Subst.shift_subst
                        (FStar_Compiler_List.length
                           action.FStar_Syntax_Syntax.action_univs)
                        binders_opening in
                    let erased_action_params =
                      match action.FStar_Syntax_Syntax.action_params with
                      | [] -> []
                      | uu___2 ->
                          let bs =
                            let uu___3 =
                              FStar_Syntax_Subst.subst_binders opening
                                action.FStar_Syntax_Syntax.action_params in
                            erase_binders uu___3 in
                          let t =
                            FStar_Syntax_Syntax.mk
                              (FStar_Syntax_Syntax.Tm_abs
                                 {
                                   FStar_Syntax_Syntax.bs = bs;
                                   FStar_Syntax_Syntax.body =
                                     FStar_Syntax_Syntax.t_unit;
                                   FStar_Syntax_Syntax.rc_opt =
                                     FStar_Pervasives_Native.None
                                 }) FStar_Compiler_Range_Type.dummyRange in
                          let uu___3 =
                            let uu___4 =
                              let uu___5 = FStar_Syntax_Subst.close binders t in
                              FStar_Syntax_Subst.compress uu___5 in
                            uu___4.FStar_Syntax_Syntax.n in
                          (match uu___3 with
                           | FStar_Syntax_Syntax.Tm_abs
                               { FStar_Syntax_Syntax.bs = bs1;
                                 FStar_Syntax_Syntax.body = uu___4;
                                 FStar_Syntax_Syntax.rc_opt = uu___5;_}
                               -> bs1
                           | uu___4 ->
                               FStar_Compiler_Effect.failwith "Impossible") in
                    let erase_term1 t =
                      let uu___2 =
                        let uu___3 = FStar_Syntax_Subst.subst opening t in
                        erase_univs uu___3 in
                      FStar_Syntax_Subst.close binders uu___2 in
                    let uu___2 =
                      erase_term1 action.FStar_Syntax_Syntax.action_defn in
                    let uu___3 =
                      erase_term1 action.FStar_Syntax_Syntax.action_typ in
                    {
                      FStar_Syntax_Syntax.action_name =
                        (action.FStar_Syntax_Syntax.action_name);
                      FStar_Syntax_Syntax.action_unqualified_name =
                        (action.FStar_Syntax_Syntax.action_unqualified_name);
                      FStar_Syntax_Syntax.action_univs = [];
                      FStar_Syntax_Syntax.action_params =
                        erased_action_params;
                      FStar_Syntax_Syntax.action_defn = uu___2;
                      FStar_Syntax_Syntax.action_typ = uu___3
                    } in
                  let uu___2 = FStar_Syntax_Subst.close_binders binders in
                  let uu___3 =
                    FStar_Syntax_Util.apply_eff_sig erase_tscheme
                      ed.FStar_Syntax_Syntax.signature in
                  let uu___4 =
                    FStar_Syntax_Util.apply_eff_combinators erase_tscheme
                      ed.FStar_Syntax_Syntax.combinators in
                  let uu___5 =
                    FStar_Compiler_List.map erase_action
                      ed.FStar_Syntax_Syntax.actions in
                  {
                    FStar_Syntax_Syntax.mname =
                      (ed.FStar_Syntax_Syntax.mname);
                    FStar_Syntax_Syntax.cattributes =
                      (ed.FStar_Syntax_Syntax.cattributes);
                    FStar_Syntax_Syntax.univs = [];
                    FStar_Syntax_Syntax.binders = uu___2;
                    FStar_Syntax_Syntax.signature = uu___3;
                    FStar_Syntax_Syntax.combinators = uu___4;
                    FStar_Syntax_Syntax.actions = uu___5;
                    FStar_Syntax_Syntax.eff_attrs =
                      (ed.FStar_Syntax_Syntax.eff_attrs);
                    FStar_Syntax_Syntax.extraction_mode =
                      (ed.FStar_Syntax_Syntax.extraction_mode)
                  } in
            let push_sigelt env se =
              match se.FStar_Syntax_Syntax.sigel with
              | FStar_Syntax_Syntax.Sig_new_effect ed ->
                  let se' =
                    let uu___ =
                      let uu___1 = erase_univs_ed ed in
                      FStar_Syntax_Syntax.Sig_new_effect uu___1 in
                    {
                      FStar_Syntax_Syntax.sigel = uu___;
                      FStar_Syntax_Syntax.sigrng =
                        (se.FStar_Syntax_Syntax.sigrng);
                      FStar_Syntax_Syntax.sigquals =
                        (se.FStar_Syntax_Syntax.sigquals);
                      FStar_Syntax_Syntax.sigmeta =
                        (se.FStar_Syntax_Syntax.sigmeta);
                      FStar_Syntax_Syntax.sigattrs =
                        (se.FStar_Syntax_Syntax.sigattrs);
                      FStar_Syntax_Syntax.sigopens_and_abbrevs =
                        (se.FStar_Syntax_Syntax.sigopens_and_abbrevs);
                      FStar_Syntax_Syntax.sigopts =
                        (se.FStar_Syntax_Syntax.sigopts)
                    } in
                  let env1 = FStar_Syntax_DsEnv.push_sigelt env se' in
                  push_reflect_effect env1 se.FStar_Syntax_Syntax.sigquals
                    ed.FStar_Syntax_Syntax.mname
                    se.FStar_Syntax_Syntax.sigrng
              | uu___ -> FStar_Syntax_DsEnv.push_sigelt env se in
            let uu___ =
              FStar_Syntax_DsEnv.prepare_module_or_interface false false en
                m.FStar_Syntax_Syntax.name mii in
            match uu___ with
            | (en1, pop_when_done) ->
                let en2 =
                  let uu___1 =
                    FStar_Syntax_DsEnv.set_current_module en1
                      m.FStar_Syntax_Syntax.name in
                  FStar_Compiler_List.fold_left push_sigelt uu___1
                    m.FStar_Syntax_Syntax.declarations in
                let en3 =
                  if finish then FStar_Syntax_DsEnv.finish en2 m else en2 in
                let uu___1 =
                  if pop_when_done
                  then
                    FStar_Syntax_DsEnv.export_interface
                      m.FStar_Syntax_Syntax.name en3
                  else en3 in
                ((), uu___1)
let (add_partial_modul_to_env :
  FStar_Syntax_Syntax.modul ->
    FStar_Syntax_DsEnv.module_inclusion_info ->
      (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
        unit FStar_Syntax_DsEnv.withenv)
  = add_modul_to_env_core false
let (add_modul_to_env :
  FStar_Syntax_Syntax.modul ->
    FStar_Syntax_DsEnv.module_inclusion_info ->
      (FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term) ->
        unit FStar_Syntax_DsEnv.withenv)
  = add_modul_to_env_core true