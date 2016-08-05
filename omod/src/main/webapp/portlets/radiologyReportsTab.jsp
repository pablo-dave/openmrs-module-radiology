<%@ include file="/WEB-INF/view/module/radiology/template/includeTags.jsp"%>
<%@ include file="/WEB-INF/view/module/radiology/template/includeScripts.jsp"%>
<%@ include file="/WEB-INF/view/module/radiology/template/includeDatatablesWithDefaults.jsp"%>
<openmrs:htmlInclude file="/moduleResources/radiology/scripts/jquery/daterangepicker/css/daterangepicker.min.css" />
<openmrs:htmlInclude file="/moduleResources/radiology/scripts/jquery/daterangepicker/js/jquery.daterangepicker.min.js" />

<script type="text/javascript">
  // configure current locale as momentjs default, fall back to "en" if locale not found
  moment.locale([jsLocale, 'en']);

  var $j = jQuery.noConflict();
  $j(document)
          .ready(
                  function() {
                    var fromDate = $j('#reportsTabFromDateFilter');
                    var toDate = $j('#reportsTabToDateFilter');
                    var principalResultsInterpreterUuid = $j('#reportsTabProviderFilter');
                    var status = $j('#reportsTabStatusSelect');
                    var find = $j('#reportsTabFind');
                    var clearResults = $j('a#reportsTabClearFilters');

                    $j('#reportsTabDateRangePicker').dateRangePicker({
                      startOfWeek: "monday",
                      customTopBar: '<b class="start-day">...</b> - <b class="end-day">...</b><i class="selected-days"> (<span class="selected-days-num">3</span>)</i>',
                      showShortcuts: true,
                      shortcuts: {
                        'prev-days': [3, 5, 7],
                        'prev': ['week', 'month'],
                        'next-days': null,
                        'next': null
                      },
                      separator: '-',
                      format: 'L',
                      getValue: function() {
                        if (fromDate.val() && toDate.val())
                          return fromDate.val() + '-' + toDate.val();
                        else
                          return '';
                      },
                      setValue: function(s, s1, s2) {
                        fromDate.val(s1);
                        toDate.val(s2);
                      }
                    });
                    
                    $j('#reportsTabDateRangePicker').data('dateRangePicker')
                    .setDateRange(
                            moment().subtract(1, 'weeks').startOf(
                                    'week').format('L'),
                            moment().subtract(1, 'weeks').endOf('week')
                                    .format('L'));
                    
                    var radiologyReportsTable = $j('#reportsTabTable')
                            .DataTable(
                                    {
                                      "processing": true,
                                      "serverSide": true,
                                      "ajax": {
                                        headers: {
                                          Accept: "application/json; charset=utf-8",
                                          "Content-Type": "text/plain; charset=utf-8",
                                        },
                                        cache: true,
                                        dataType: "json",
                                        url: Radiology.getRestRootEndpoint()
                                                + "/radiologyreport/",
                                        data: function(data) {
                                          return {
                                            startIndex: data.start,
                                            limit: data.length,
                                            v: "full",
                                            fromdate: fromDate.val() === ""
                                                    ? ""
                                                    : moment(fromDate.val(),
                                                            "L")
                                                            .format(
                                                                    "YYYY-MM-DDTHH:mm:ss.SSSZ"),
                                            todate: toDate.val() === ""
                                                    ? ""
                                                    : moment(toDate.val(), "L")
                                                            .format(
                                                                    "YYYY-MM-DDTHH:mm:ss.SSSZ"),
                                            principalResultsInterpreter: principalResultsInterpreterUuid
                                                    .val(),
                                            status: status.val(),
                                            totalCount: true,
                                          };
                                        },
                                        "dataFilter": function(data) {
                                          var json = $j.parseJSON(data);
                                          json.recordsTotal = json.totalCount || 0;
                                          json.recordsFiltered = json.totalCount || 0;
                                          json.data = json.results;
                                          return JSON.stringify(json);
                                        }
                                      },
                                      "columns": [
                                          {
                                            "className": "control",
                                            "orderable": false,
                                            "data": null,
                                            "defaultContent": "",
                                            "responsivePriority": 1
                                          },
                                          {
                                            "name": "radiologyOrder",
                                            "responsivePriority": 1,
                                            "render": function(data, type,
                                                    full, meta) {
                                              return full.radiologyOrder.display;
                                            }
                                          },
                                          {
                                            "name": "principalResultsInterpreter",
                                            "render": function(data, type,
                                                    full, meta) {

                                              return Radiology
                                                      .getProperty(full,
                                                              "principalResultsInterpreter.display");
                                            }
                                          },
                                          {
                                            "name": "date",
                                            "render": function(data, type,
                                                    full, meta) {
                                              var result = "";
                                              if (full.date) {
                                                result = moment(full.date)
                                                        .format("LL");
                                              }
                                              return result;
                                            }
                                          },
                                          {
                                            "name": "dateCreated",
                                            "responsivePriority": 11000,
                                            "render": function(data, type,
                                                    full, meta) {
                                              var result = "";
                                              if (full.auditInfo.dateCreated) {
                                                result = moment(
                                                        full.auditInfo.dateCreated)
                                                        .format("LLL");
                                              }
                                              return result;
                                            }
                                          },
                                          {
                                            "name": "creatorBy",
                                            "responsivePriority": 11000,
                                            "render": function(data, type,
                                                    full, meta) {
                                              return full.auditInfo.creator.display;
                                            }
                                          },
                                          {
                                            "name": "status",
                                            "className": "dt-center",
                                            "render": function(data, type,
                                                    full, meta) {
                                              switch (full.status) {
                                              case "COMPLETED":
                                                return '<i title="<spring:message code="radiology.report.status.COMPLETED"/>" class="fa fa-check-circle fa-lg"></i>';
                                              case "CLAIMED":
                                                return '<i title="<spring:message code="radiology.report.status.CLAIMED"/>" class="fa fa-circle fa-lg"></i>';
                                              case "DISCONTINUED":
                                                return '<i title="<spring:message code="radiology.report.status.DISCONTINUED"/>" class="fa fa-times-circle fa-lg"></i>';
                                              }
                                            }
                                          },
                                          {
                                            "name": "action",
                                            "className": "dt-center",
                                            "responsivePriority": 1,
                                            "render": function(data, type,
                                                    full, meta) {
                                              return '<a href="${pageContext.request.contextPath}/module/radiology/radiologyReport.form?reportId='
                                                      + full.uuid
                                                      + '"><i class="fa fa-eye fa-lg"></i></a>';
                                            }
                                          }],
                                    });

                    // prevent form submit when user hits enter
                    $j(window).keydown(function(event) {
                      if (event.keyCode == 13) {
                        event.preventDefault();
                        return false;
                      }
                    });

                    find.on('mouseup keyup', function(event) {
                      if (event.type == 'keyup' && event.keyCode != 13) return;
                      radiologyReportsTable.ajax.reload();
                    });

                    clearResults
                            .on(
                                    'mouseup keyup',
                                    function() {
                                      $j(
                                              '#reportsTabTableFilterFields input, #reportsTabTableFilterFields select')
                                              .val('');
                                      $j('#reportsTabDateRangePicker').data(
                                              'dateRangePicker').clear();
                                      radiologyReportsTable.ajax.reload();
                                    });
                  });
</script>

<br>
<span class="boxHeader"> <b><spring:message code="radiology.report.boxheader" /></b> <a id="reportsTabClearFilters"
  href="#" style="float: right"> <spring:message code="radiology.dashboard.tabs.filters.clearFilters" />
</a>
</span>
<div class="box">
  <table cellspacing="10">
    <tr>
      <form>
        <td id="reportsTabTableFilterFields"><label><spring:message
              code="radiology.dashboard.tabs.filters.filterby" /></label> <span id="reportsTabDateRangePicker"> <input
            type="text" id="reportsTabFromDateFilter"
            placeholder='<spring:message code="radiology.dashboard.tabs.reports.filters.date.from" />' /> <span>-</span> <input
            type="text" id="reportsTabToDateFilter"
            placeholder='<spring:message code="radiology.dashboard.tabs.reports.filters.date.to" />' />
        </span> <radiology:providerField formFieldName="principalResultsInterpreter" formFieldId="reportsTabProviderFilter" /> <select
          id="reportsTabStatusSelect">
            <c:forEach var="radiologyReportStatus" items="${model.radiologyReportStatuses}">
              <option value="${radiologyReportStatus}">
                <c:choose>
                  <c:when test="${not empty radiologyReportStatus}">
                    <spring:message code="radiology.report.status.${radiologyReportStatus}" text="${radiologyReportStatus}" />
                  </c:when>
                  <c:otherwise>
                    <spring:message code="radiology.report.status.selectStatus" />
                  </c:otherwise>
                </c:choose>
              </option>
            </c:forEach>
        </select></td>
        <td><input id="reportsTabFind" type="button"
          value="<spring:message code="radiology.dashboard.tabs.filters.filter"/>" /></td>
      </form>
    </tr>
  </table>
  <br>
  <div>
    <table id="reportsTabTable" cellspacing="0" width="100%" class="display responsive compact">
      <thead>
        <tr>
          <th></th>
          <th><spring:message code="radiology.datatables.column.report.order" /></th>
          <th><spring:message code="radiology.datatables.column.report.principalResultsInterpreter" /></th>
          <th><spring:message code="radiology.datatables.column.report.date" /></th>
          <th><spring:message code="radiology.datatables.column.report.dateCreated" /></th>
          <th><spring:message code="radiology.datatables.column.report.createdBy" /></th>
          <th><spring:message code="radiology.datatables.column.report.status" /></th>
          <th><spring:message code="radiology.datatables.column.action" /></th>
        </tr>
      </thead>
    </table>
  </div>
</div>
