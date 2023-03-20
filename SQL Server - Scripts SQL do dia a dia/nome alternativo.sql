select processoTrf.id_processo_trf)
from client.tb_processo_trf processoTrf
INNER JOIN client.tb_processo_parte processoParte 
             ON processoTrf.id_processo_trf = processoParte.id_processo_trf
INNER JOIN client.tb_pessoa pessoa
             ON processoParte.id_pessoa = pessoa.id_pessoa
INNER JOIN client.tb_pess_doc_identificacao pessDocIdentificacao
             ON pessoa.id_pessoa = pessDocIdentificacao.id_pessoa
            AND (pessDocIdentificacao.in_usado_falsamente = false
            AND pessDocIdentificacao.in_ativo = true
            AND pessDocIdentificacao.in_principal = true)
LEFT OUTER JOIN client.tb_pessoa_nome_alternativo pessNomeAlernatvio
             ON pessoa.id_pessoa = pessNomeAlernatvio.id_pessoa
where 1 = 1
  AND processoTrf.cd_nivel_acesso < 4
  AND (lower(to_ascii( pessDocIdentificacao.ds_nome_pessoa)) ilike '%'|| lower(to_ascii('%JÚNIOR%')) ||'%'
       OR lower(to_ascii(pessNomeAlernatvio.ds_pessoa_nome_alternativo)) ilike '%'|| lower(to_ascii('%JÚNIOR%')) ||'%'
       )
  AND processoParte.in_situacao IN ('A')
  and processotrf.cd_processo_status = 'D'
GROUP by processoTrf.id_processo_trf