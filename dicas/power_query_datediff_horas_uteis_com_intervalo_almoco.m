/*
   
   A função a seguir tem como objetivo extrair a quantidade de horas úteis entre duas datas no formato Datetime (dd/mm/yyyy hh:MM:ss) considerando:

        - Dias Úteis em uma semana
        - Excluindo feriados, informados através de uma Lista
        - Considerando horas úteis, entre um intervalo de expediente informado.

*/


(Abertura, Fechamento, InicioExpediente, FimExpediente, SaidaIntervalo, RetornoIntervalo, ListaFeriados) =>

let 

DiaDaAbertura   = Number.From(DateTime.Date(Abertura)),
DiaDoFechamento = Number.From(DateTime.Date(Fechamento)),

HorarioDaAbertura   = Number.From(DateTime.Time(Abertura)),
HorarioDoFechamento = Number.From(DateTime.Time(Fechamento)),


// Seleciona somente Dias Úteis Semanais
ListaDeDatas = List.Select({DiaDaAbertura..DiaDoFechamento}, each Number.Mod(_,7)>1),

// Exclui Feriados
ListaDiasUteis = List.Difference(ListaDeDatas,ListaFeriados),

SomaHorasUteis = 
        // Verifica se o dia de abertura é igual ao de Fechamento 

        // // Caso 01: Dia da Abertura é igual ao dia do Fechamento
        if DiaDaAbertura = DiaDoFechamento then

                // Verifica se o dia da abertura é um dia útil
                if DiaDaAbertura = List.First(ListaDiasUteis) then

                        // Qual horário considerar para o fim do Expediente?
                        ( 
                                if HorarioDoFechamento > RetornoIntervalo then
                                        List.Median({RetornoIntervalo, FimExpediente, HorarioDoFechamento })

                                else 
                                        List.Median({InicioExpediente, SaidaIntervalo, HorarioDoFechamento })
                        
                        )
                        -
                        (
                                // Qual horário considerar para o inicio do Expediente?
                                if HorarioDaAbertura > RetornoIntervalo then                                
                                        List.Median({RetornoIntervalo, FimExpediente, HorarioDaAbertura })

                                else
                                        List.Median({InicioExpediente, SaidaIntervalo, HorarioDaAbertura })                        
                        )

                        

                else 0

        // Caso 02: Dia da Abertura não é igual ao dia do Fechamento
        else (
                // Verifica se o dia da abertura é dia útil
                if DiaDaAbertura = List.First(ListaDiasUteis) then                        
                        
                                FimExpediente -
                        
                                (       
                                        // Qual horário considerar para o inicio do Expediente?
                                        if HorarioDaAbertura > RetornoIntervalo then  

                                                List.Median({RetornoIntervalo, FimExpediente, HorarioDaAbertura }) 

                                        else
                                                List.Median({InicioExpediente, SaidaIntervalo, HorarioDaAbertura }) 

                                )                 
                else 0
        ) 
        - 
        (RetornoIntervalo - SaidaIntervalo)
        +
        (       // Verifica se o dia de fechamento é dia útil 
                if DiaDoFechamento = List.Last(ListaDiasUteis) then                        
                          
                                (    
                                        // Qual horário considerar para o fim do Expediente?
                                        if HorarioDoFechamento > RetornoIntervalo then  

                                                List.Median({RetornoIntervalo, FimExpediente, HorarioDoFechamento }) 

                                        else
                                                List.Median({InicioExpediente, SaidaIntervalo, HorarioDoFechamento })

                                ) 
                                - InicioExpediente
                        
                       
                else 0
        )
        +
        (
                //Soma total de horas úteis dos dias entre a Abertura e Fechamento
                List.Count(List.Difference(ListaDiasUteis,{DiaDaAbertura,DiaDoFechamento}))*( ( FimExpediente - RetornoIntervalo ) + ( SaidaIntervalo - InicioExpediente) )
        )

in 

SomaHorasUteis