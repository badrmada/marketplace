{{/*
Expand the name of the chart.
*/}}
{{- define "php-multisite.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "php-multisite.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "php-multisite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "php-multisite.labels" -}}
helm.sh/chart: {{ include "php-multisite.chart" . }}
{{ include "php-multisite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "php-multisite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "php-multisite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "php-multisite.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "php-multisite.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the PVC to use
*/}}
{{- define "php-multisite.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- printf "%s-userdata" (include "php-multisite.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Create the TLS secret name
*/}}
{{- define "php-multisite.tlsSecretName" -}}
{{- if .Values.ingress.tls.secretName -}}
{{- .Values.ingress.tls.secretName -}}
{{- else -}}
{{- printf "%s-tls" (include "php-multisite.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Generate backend protocol annotation based on service configuration
*/}}
{{- define "php-multisite.backendProtocol" -}}
{{- if .Values.service.tls -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for PodDisruptionBudget
*/}}
{{- define "php-multisite.pdb.apiVersion" -}}
{{- if .Capabilities.APIVersions.Has "policy/v1" -}}
{{- print "policy/v1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Get the user name
*/}}
{{- define "php-multisite.userName" -}}
{{- .Values.username | default .Release.Namespace -}}
{{- end -}}

{{/*
Generate resource name with user prefix
*/}}
{{- define "php-multisite.resourceName" -}}
{{- $userName := include "php-multisite.userName" . -}}
{{- printf "%s-php" $userName -}}
{{- end -}}

{{/*
Render image repository and tag
*/}}
{{- define "php-multisite.phpImage" -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- end -}}

{{/*
Render Nginx image repository and tag
*/}}
{{- define "php-multisite.nginxImage" -}}
{{- printf "%s:%s" .Values.image.nginx.repository .Values.image.nginx.tag -}}
{{- end -}}

{{/*
Return the proper storage class name
*/}}
{{- define "php-multisite.storageClass" -}}
{{- if .Values.persistence.storageClass -}}
{{- if (eq "-" .Values.persistence.storageClass) -}}
storageClassName: ""
{{- else -}}
storageClassName: {{ .Values.persistence.storageClass }}
{{- end -}}
{{- end -}}
{{- end -}}