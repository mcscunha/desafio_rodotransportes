/*
   A função tem como objetivo extrair a quantidade de horas úteis entre duas datas
   excluindo feriados informados como parâmetro e também um expediente ( hora de inicio e fim)

*/


(InicioExpedienteSemanal, FimExpedienteSemanal, InicioExpedienteSabado, FimExpedienteSabado, AberturaChamado, FechamentoChamado, ListaFeriados) =>

let 

DiaDaAbertura   = Number.From(DateTime.Date(AberturaChamado)),
DiaDoFechamento = Number.From(DateTime.Date(FechamentoChamado)),

HorarioDaAbertura   = Number.From(DateTime.Time(AberturaChamado)),
HorarioDoFechamento = Number.From(DateTime.Time(FechamentoChamado)),

// Lista dos dias Úteis, considerando sábado como útil
ListaDeDatas = List.Select({DiaDaAbertura..DiaDoFechamento}, each Number.Mod(_,7)<>1),


// Exclui da lista de dados os Feriados Informados
ListaDiasUteis = List.Difference(ListaDeDatas,ListaFeriados),


SomaHorasUteis = 
        // Verifica se o dia da abertua é igual ao dia do fechamento
        if DiaDaAbertura = DiaDoFechamento then
                // Verifica se o dia da abertura é Feriado        
                if DiaDaAbertura = List.First(ListaDiasUteis) then                        
                        // Verifica se o dia da abertura é Sábado
                        if DiaDaAbertura = 0 then
                                List.Median({InicioExpedienteSabado, FimExpedienteSabado, HorarioDoFechamento }) - List.Median({InicioExpedienteSabado, FimExpedienteSabado, HorarioDaAbertura})
                        else
                                List.Median({InicioExpedienteSemanal,FimExpedienteSemanal,HorarioDoFechamento}) - List.Median({InicioExpedienteSemanal,FimExpedienteSemanal,HorarioDaAbertura})
                else 0
        else (
                // Verifica se o dia da abertura é dia útil (DtAbertura <> DtFechamento)
                if DiaDaAbertura = List.First(ListaDiasUteis) then
                        // Verifica se o dia da abertura é Sábado
                        if DiaDaAbertura = 0 then
                                FimExpedienteSabado - List.Median({InicioExpedienteSabado, FimExpedienteSabado, HorarioDaAbertura })
                        else
                                FimExpedienteSemanal - List.Median({InicioExpedienteSemanal,FimExpedienteSemanal,HorarioDaAbertura})
                else 0
        )
        +
        (       // Verifica se o dia de fechamento é dia útil (DtAbertura <> DtFechamento)
                if DiaDoFechamento = List.Last(ListaDiasUteis) then 
                        // Verifica se o dia da abertura é Sábado
                        if DiaDaAbertura = 0 then
                                List.Median({InicioExpedienteSabado, FimExpedienteSabado, HorarioDoFechamento}) - InicioExpedienteSabado
                        else 
                                List.Median({InicioExpedienteSemanal, FimExpedienteSemanal, HorarioDoFechamento}) - InicioExpedienteSemanal
                else 0
        )
        +
        (
                ( List.Count( List.Select(List.Difference(ListaDiasUteis,{DiaDaAbertura,DiaDoFechamento}), each Number.Mod(_,7) = 0) ) * (FimExpedienteSabado - InicioExpedienteSabado) )
                + 
                ( List.Count( List.Select(List.Difference(ListaDiasUteis,{DiaDaAbertura,DiaDoFechamento}), each Number.Mod(_,7) <> 0) ) * (FimExpedienteSemanal - InicioExpedienteSemanal) )
                
        )

in 

SomaHorasUteis