{{/* Merge the local chart values and the common chart defaults */}}
{{- define "common.values.setup" -}}
  {{- if .Values.common -}}
    {{- $defaultValues := deepCopy .Values.common -}}
    {{- $userValues := deepCopy (omit .Values "common") -}}
    {{- $mergedValues := mustMergeOverwrite $defaultValues $userValues -}}
    {{- $_ := set . "Values" (deepCopy $mergedValues) -}}
  {{- end -}}

  {{/* merge persistenceList with Persitence */}}
  {{- $perDict := dict }}
  {{- range $index, $item := .Values.persistenceList -}}
    {{- $name := ( printf "list-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $perDict $name $item }}
  {{- end }}

  {{/* merge deviceList with Persitence */}}
  {{- range $index, $item := .Values.deviceList -}}
    {{- $name := ( printf "device-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $perDict $name $item }}
  {{- end }}
  {{- $per := merge .Values.persistence $perDict }}
  {{- $_ := set .Values "persistence" (deepCopy $per) -}}


  {{/* merge ingressList with ingress */}}
  {{- $ingDict := dict }}
  {{- range $index, $item := .Values.ingressList -}}
    {{- $name := ( printf "list-%s" ( $index | toString ) ) }}
    {{- if $item.name }}
      {{- $name = $item.name }}
    {{- end }}
    {{- $_ := set $ingDict $name $item }}
  {{- end }}
  {{- $ing := merge .Values.ingress $ingDict }}
  {{- $_ := set .Values "ingress" (deepCopy $ing) -}}

  {{/* Enable privileged securitycontext when deviceList is used */}}
  {{- if .Values.securityContext.privileged }}
  {{- else if .Values.deviceList }}
  {{- $_ := set .Values.securityContext "privileged" true -}}
  {{- end }}

  {{/* save supplementalGroups to placeholder variable */}}
  {{- $supGroups := list }}
  {{ if .Values.podSecurityContext.supplementalGroups }}
  {{- $supGroups = .Values.podSecurityContext.supplementalGroups }}
  {{- end }}

  {{/* Append requered groups to supplementalGroups when deviceList is used */}}
  {{- if .Values.deviceList}}
  {{- $devGroups := list 5 20 24 }}
  {{- $supGroups := list ( concat $supGroups $devGroups ) }}
  {{- end }}

  {{/* Append requered groups to supplementalGroups when scaleGPU is used */}}
  {{- if .Values.scaleGPU }}
  {{- $gpuGroups := list 44 107 }}
  {{- $supGroups := list ( concat $supGroups $gpuGroups ) }}
  {{- end }}

  {{/* write appended supplementalGroups to .Values */}}
  {{- $_ := set .Values.podSecurityContext "supplementalGroups" $supGroups -}}

{{- end -}}
