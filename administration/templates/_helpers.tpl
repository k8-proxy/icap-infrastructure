{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "icap-administration.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "icap-administration.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create unified labels for icap-administration components
*/}}
{{- define "icap-administration.common.matchLabels" -}}
app: {{ template "icap-administration.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "icap-administration.common.metaLabels" -}}
chart: {{ template "icap-administration.chart" . }}
heritage: {{ .Release.Service }}
{{- end -}}

{{- define "policy-management-api.labels" -}}
{{ include "policy-management-api.matchLabels" . }}
{{ include "icap-administration.common.metaLabels" . }}
{{- end -}}

{{- define "policy-management-api.matchLabels" -}}
component: {{ .Values.policymanagementapi.name | quote }}
{{ include "icap-administration.common.matchLabels" . }}
{{- end -}}

{{- define "transactionqueryaggregator.labels" -}}
{{ include "transactionqueryaggregator.matchLabels" . }}
{{ include "icap-administration.common.metaLabels" . }}
{{- end -}}

{{- define "transactionqueryaggregator.matchLabels" -}}
component: {{ .Values.transactionqueryaggregator.name | quote }}
{{ include "icap-administration.common.matchLabels" . }}
{{- end -}}

{{- define "identitymanagementservice.labels" -}}
{{ include "identitymanagementservice.matchLabels" . }}
{{ include "icap-administration.common.metaLabels" . }}
{{- end -}}

{{- define "identitymanagementservice.matchLabels" -}}
component: {{ .Values.identitymanagementservice.name | quote }}
{{ include "icap-administration.common.matchLabels" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "icap-administration.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified policy-management-api name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "policy-management-api.fullname" -}}
{{- if .Values.policymanagementapi.fullnameOverride -}}
{{- .Values.policymanagementapi.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.policymanagementapi.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.policymanagementapi.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified transactionqueryaggregator name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "transactionqueryaggregator.fullname" -}}
{{- if .Values.transactionqueryaggregator.fullnameOverride -}}
{{- .Values.transactionqueryaggregator.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.transactionqueryaggregator.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.transactionqueryaggregator.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}


{{/*
Create a fully qualified identitymanagementservice name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "identitymanagementservice.fullname" -}}
{{- if .Values.identitymanagementservice.fullnameOverride -}}
{{- .Values.identitymanagementservice.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.identitymanagementservice.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.identitymanagementservice.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}