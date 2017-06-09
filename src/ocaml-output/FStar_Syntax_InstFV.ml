open Prims
type inst_t = (FStar_Ident.lident* FStar_Syntax_Syntax.universes) Prims.list
let mk t s =
  let uu____26 = FStar_ST.read t.FStar_Syntax_Syntax.tk in
  FStar_Syntax_Syntax.mk s uu____26 t.FStar_Syntax_Syntax.pos
let rec inst:
  (FStar_Syntax_Syntax.term ->
     FStar_Syntax_Syntax.fv -> FStar_Syntax_Syntax.term)
    -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term
  =
  fun s  ->
    fun t  ->
      let t1 = FStar_Syntax_Subst.compress t in
      let mk1 = mk t1 in
      match t1.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Tm_delayed uu____123 -> failwith "Impossible"
      | FStar_Syntax_Syntax.Tm_name uu____144 -> t1
      | FStar_Syntax_Syntax.Tm_uvar uu____145 -> t1
      | FStar_Syntax_Syntax.Tm_uvar uu____156 -> t1
      | FStar_Syntax_Syntax.Tm_type uu____167 -> t1
      | FStar_Syntax_Syntax.Tm_bvar uu____168 -> t1
      | FStar_Syntax_Syntax.Tm_constant uu____169 -> t1
      | FStar_Syntax_Syntax.Tm_unknown  -> t1
      | FStar_Syntax_Syntax.Tm_uinst uu____170 -> t1
      | FStar_Syntax_Syntax.Tm_fvar fv -> s t1 fv
      | FStar_Syntax_Syntax.Tm_abs (bs,body,lopt) ->
          let bs1 = inst_binders s bs in
          let body1 = inst s body in
          let uu____203 =
            let uu____204 =
              let uu____219 = inst_lcomp_opt s lopt in
              (bs1, body1, uu____219) in
            FStar_Syntax_Syntax.Tm_abs uu____204 in
          mk1 uu____203
      | FStar_Syntax_Syntax.Tm_arrow (bs,c) ->
          let bs1 = inst_binders s bs in
          let c1 = inst_comp s c in
          mk1 (FStar_Syntax_Syntax.Tm_arrow (bs1, c1))
      | FStar_Syntax_Syntax.Tm_refine (bv,t2) ->
          let bv1 =
            let uu___149_257 = bv in
            let uu____258 = inst s bv.FStar_Syntax_Syntax.sort in
            {
              FStar_Syntax_Syntax.ppname =
                (uu___149_257.FStar_Syntax_Syntax.ppname);
              FStar_Syntax_Syntax.index =
                (uu___149_257.FStar_Syntax_Syntax.index);
              FStar_Syntax_Syntax.sort = uu____258
            } in
          let t3 = inst s t2 in mk1 (FStar_Syntax_Syntax.Tm_refine (bv1, t3))
      | FStar_Syntax_Syntax.Tm_app (t2,args) ->
          let uu____278 =
            let uu____279 =
              let uu____289 = inst s t2 in
              let uu____290 = inst_args s args in (uu____289, uu____290) in
            FStar_Syntax_Syntax.Tm_app uu____279 in
          mk1 uu____278
      | FStar_Syntax_Syntax.Tm_match (t2,pats) ->
          let pats1 =
            FStar_All.pipe_right pats
              (FStar_List.map
                 (fun uu____367  ->
                    match uu____367 with
                    | (p,wopt,t3) ->
                        let wopt1 =
                          match wopt with
                          | None  -> None
                          | Some w ->
                              let uu____393 = inst s w in Some uu____393 in
                        let t4 = inst s t3 in (p, wopt1, t4))) in
          let uu____398 =
            let uu____399 = let uu____415 = inst s t2 in (uu____415, pats1) in
            FStar_Syntax_Syntax.Tm_match uu____399 in
          mk1 uu____398
      | FStar_Syntax_Syntax.Tm_ascribed (t11,asc,f) ->
          let inst_asc uu____471 =
            match uu____471 with
            | (annot,topt) ->
                let topt1 = FStar_Util.map_opt topt (inst s) in
                let annot1 =
                  match annot with
                  | FStar_Util.Inl t2 ->
                      let uu____512 = inst s t2 in FStar_Util.Inl uu____512
                  | FStar_Util.Inr c ->
                      let uu____520 = inst_comp s c in
                      FStar_Util.Inr uu____520 in
                (annot1, topt1) in
          let uu____530 =
            let uu____531 =
              let uu____549 = inst s t11 in
              let uu____550 = inst_asc asc in (uu____549, uu____550, f) in
            FStar_Syntax_Syntax.Tm_ascribed uu____531 in
          mk1 uu____530
      | FStar_Syntax_Syntax.Tm_let (lbs,t2) ->
          let lbs1 =
            let uu____582 =
              FStar_All.pipe_right (snd lbs)
                (FStar_List.map
                   (fun lb  ->
                      let uu___150_588 = lb in
                      let uu____589 = inst s lb.FStar_Syntax_Syntax.lbtyp in
                      let uu____592 = inst s lb.FStar_Syntax_Syntax.lbdef in
                      {
                        FStar_Syntax_Syntax.lbname =
                          (uu___150_588.FStar_Syntax_Syntax.lbname);
                        FStar_Syntax_Syntax.lbunivs =
                          (uu___150_588.FStar_Syntax_Syntax.lbunivs);
                        FStar_Syntax_Syntax.lbtyp = uu____589;
                        FStar_Syntax_Syntax.lbeff =
                          (uu___150_588.FStar_Syntax_Syntax.lbeff);
                        FStar_Syntax_Syntax.lbdef = uu____592
                      })) in
            ((fst lbs), uu____582) in
          let uu____597 =
            let uu____598 = let uu____606 = inst s t2 in (lbs1, uu____606) in
            FStar_Syntax_Syntax.Tm_let uu____598 in
          mk1 uu____597
      | FStar_Syntax_Syntax.Tm_meta
          (t2,FStar_Syntax_Syntax.Meta_pattern args) ->
          let uu____622 =
            let uu____623 =
              let uu____628 = inst s t2 in
              let uu____629 =
                let uu____630 =
                  FStar_All.pipe_right args (FStar_List.map (inst_args s)) in
                FStar_Syntax_Syntax.Meta_pattern uu____630 in
              (uu____628, uu____629) in
            FStar_Syntax_Syntax.Tm_meta uu____623 in
          mk1 uu____622
      | FStar_Syntax_Syntax.Tm_meta
          (t2,FStar_Syntax_Syntax.Meta_monadic (m,t')) ->
          let uu____670 =
            let uu____671 =
              let uu____676 = inst s t2 in
              let uu____677 =
                let uu____678 = let uu____683 = inst s t' in (m, uu____683) in
                FStar_Syntax_Syntax.Meta_monadic uu____678 in
              (uu____676, uu____677) in
            FStar_Syntax_Syntax.Tm_meta uu____671 in
          mk1 uu____670
      | FStar_Syntax_Syntax.Tm_meta (t2,tag) ->
          let uu____690 =
            let uu____691 = let uu____696 = inst s t2 in (uu____696, tag) in
            FStar_Syntax_Syntax.Tm_meta uu____691 in
          mk1 uu____690
and inst_binders:
  (FStar_Syntax_Syntax.term ->
     FStar_Syntax_Syntax.fv -> FStar_Syntax_Syntax.term)
    ->
    FStar_Syntax_Syntax.binders ->
      (FStar_Syntax_Syntax.bv* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun s  ->
    fun bs  ->
      FStar_All.pipe_right bs
        (FStar_List.map
           (fun uu____710  ->
              match uu____710 with
              | (x,imp) ->
                  let uu____717 =
                    let uu___151_718 = x in
                    let uu____719 = inst s x.FStar_Syntax_Syntax.sort in
                    {
                      FStar_Syntax_Syntax.ppname =
                        (uu___151_718.FStar_Syntax_Syntax.ppname);
                      FStar_Syntax_Syntax.index =
                        (uu___151_718.FStar_Syntax_Syntax.index);
                      FStar_Syntax_Syntax.sort = uu____719
                    } in
                  (uu____717, imp)))
and inst_args:
  (FStar_Syntax_Syntax.term ->
     FStar_Syntax_Syntax.fv -> FStar_Syntax_Syntax.term)
    ->
    ((FStar_Syntax_Syntax.term',FStar_Syntax_Syntax.term')
      FStar_Syntax_Syntax.syntax* FStar_Syntax_Syntax.aqual) Prims.list ->
      (FStar_Syntax_Syntax.term* FStar_Syntax_Syntax.aqual) Prims.list
  =
  fun s  ->
    fun args  ->
      FStar_All.pipe_right args
        (FStar_List.map
           (fun uu____745  ->
              match uu____745 with
              | (a,imp) -> let uu____752 = inst s a in (uu____752, imp)))
and inst_comp:
  (FStar_Syntax_Syntax.term ->
     FStar_Syntax_Syntax.fv -> FStar_Syntax_Syntax.term)
    ->
    (FStar_Syntax_Syntax.comp',Prims.unit) FStar_Syntax_Syntax.syntax ->
      FStar_Syntax_Syntax.comp
  =
  fun s  ->
    fun c  ->
      match c.FStar_Syntax_Syntax.n with
      | FStar_Syntax_Syntax.Total (t,uopt) ->
          let uu____771 = inst s t in
          FStar_Syntax_Syntax.mk_Total' uu____771 uopt
      | FStar_Syntax_Syntax.GTotal (t,uopt) ->
          let uu____780 = inst s t in
          FStar_Syntax_Syntax.mk_GTotal' uu____780 uopt
      | FStar_Syntax_Syntax.Comp ct ->
          let ct1 =
            let uu___152_783 = ct in
            let uu____784 = inst s ct.FStar_Syntax_Syntax.result_typ in
            let uu____787 = inst_args s ct.FStar_Syntax_Syntax.effect_args in
            let uu____793 =
              FStar_All.pipe_right ct.FStar_Syntax_Syntax.flags
                (FStar_List.map
                   (fun uu___148_797  ->
                      match uu___148_797 with
                      | FStar_Syntax_Syntax.DECREASES t ->
                          let uu____801 = inst s t in
                          FStar_Syntax_Syntax.DECREASES uu____801
                      | f -> f)) in
            {
              FStar_Syntax_Syntax.comp_univs =
                (uu___152_783.FStar_Syntax_Syntax.comp_univs);
              FStar_Syntax_Syntax.effect_name =
                (uu___152_783.FStar_Syntax_Syntax.effect_name);
              FStar_Syntax_Syntax.result_typ = uu____784;
              FStar_Syntax_Syntax.effect_args = uu____787;
              FStar_Syntax_Syntax.flags = uu____793
            } in
          FStar_Syntax_Syntax.mk_Comp ct1
and inst_lcomp_opt:
  (FStar_Syntax_Syntax.term ->
     FStar_Syntax_Syntax.fv -> FStar_Syntax_Syntax.term)
    ->
    (FStar_Syntax_Syntax.lcomp,(FStar_Ident.lident*
                                 FStar_Syntax_Syntax.cflags Prims.list))
      FStar_Util.either option ->
      (FStar_Syntax_Syntax.lcomp,(FStar_Ident.lident*
                                   FStar_Syntax_Syntax.cflags Prims.list))
        FStar_Util.either option
  =
  fun s  ->
    fun l  ->
      match l with
      | None  -> l
      | Some (FStar_Util.Inr uu____828) -> l
      | Some (FStar_Util.Inl lc) ->
          let uu____849 =
            let uu____855 =
              let uu___153_856 = lc in
              let uu____857 = inst s lc.FStar_Syntax_Syntax.res_typ in
              {
                FStar_Syntax_Syntax.eff_name =
                  (uu___153_856.FStar_Syntax_Syntax.eff_name);
                FStar_Syntax_Syntax.res_typ = uu____857;
                FStar_Syntax_Syntax.cflags =
                  (uu___153_856.FStar_Syntax_Syntax.cflags);
                FStar_Syntax_Syntax.comp =
                  (fun uu____860  ->
                     let uu____861 = lc.FStar_Syntax_Syntax.comp () in
                     inst_comp s uu____861)
              } in
            FStar_Util.Inl uu____855 in
          Some uu____849
let instantiate:
  inst_t -> FStar_Syntax_Syntax.term -> FStar_Syntax_Syntax.term =
  fun i  ->
    fun t  ->
      match i with
      | [] -> t
      | uu____880 ->
          let inst_fv t1 fv =
            let uu____888 =
              FStar_Util.find_opt
                (fun uu____894  ->
                   match uu____894 with
                   | (x,uu____898) ->
                       FStar_Ident.lid_equals x
                         (fv.FStar_Syntax_Syntax.fv_name).FStar_Syntax_Syntax.v)
                i in
            match uu____888 with
            | None  -> t1
            | Some (uu____905,us) ->
                mk t1 (FStar_Syntax_Syntax.Tm_uinst (t1, us)) in
          inst inst_fv t