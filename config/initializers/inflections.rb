# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
    inflect.irregular 'ente_gestito', 'enti_gestiti'
    inflect.irregular 'applicazioni_ente', 'applicazioni_ente'
    inflect.irregular 'clienti_allegato', 'clienti_allegati'
    inflect.irregular 'clienti_applicazione', 'clienti_applicazioni'
    inflect.irregular 'clienti_applinstallate', 'clienti_applinstallate'
    inflect.irregular 'clienti_attivazione', 'clienti_attivazioni'
    inflect.irregular 'clienti_cliente', 'clienti_clienti'
    inflect.irregular 'clienti_dettordine', 'clienti_dettordini'
    inflect.irregular 'clienti_installazione', 'clienti_installazioni'
    inflect.irregular 'clienti_linkfunzione', 'clienti_linkfunzioni'
    inflect.irregular 'clienti_ordine', 'clienti_ordini'
    inflect.irregular 'clienti_scadenza', 'clienti_scadenze'
    inflect.irregular 'clienti_server', 'clienti_server'
    inflect.irregular 'clienti_statistica', 'clienti_statistiche'
    inflect.irregular 'clienti_tipostatistica', 'clienti_tipostatistiche'
    inflect.irregular 'ente_gestito', 'enti_gestiti'
    
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym 'RESTful'
# end