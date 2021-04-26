CHART_REPO := http://jenkins-x-chartmuseum.jx.svc.cluster.local:8080
NAME := acme-environments
build: clean
	helm lint

clean:
	rm -rf charts
	rm -rf ${NAME}*.tgz

release: clean
	sed -i -e "s/version:.*/version: $(VERSION)/" Chart.yaml
	helm lint
	helm package .
	helm repo add tf-api $(CHART_REPO)
	helm plugin install https://github.com/chartmuseum/helm-push.git
	helm push ${NAME}*.tgz tf-api --public