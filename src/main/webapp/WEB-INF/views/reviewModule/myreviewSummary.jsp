<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!--  평가 요약  -->
<div class="container my-5">
  <div class="p-4 border rounded bg-light shadow-sm">
    <h4 class="mb-3">
      <span class="me-2"><strong>${memberId}</strong>님의 영화 평가 성향을 요약해드릴게요.</p></span>
    </h4>
    <hr />
    <ul class="mb-0">
      <li>총 <strong>${userRatingCount}</strong>개의 영화에 만족도 별점을 주셨고, 평균 별점은 <strong><fmt:formatNumber value="${averageUserRating}" maxFractionDigits="1"/></strong>점입니다.</li>
      <li>총 <strong>${violenceScoreCount}</strong>개의 영화에 폭력성 점수를 주셨고, 평균 점수는 <strong><fmt:formatNumber value="${averageViolenceScore}" maxFractionDigits="1"/></strong>점입니다.</li>
      <li>긍정적인 평가(★8 이상)는 <strong>${positiveRatingTotal}</strong>회, 부정적인 평가(★4 이하)는 <strong>${negativeRatingTotal}</strong>회 이루어졌습니다.</li>
      <c:if test="${not empty sortedGenreStats}">
        <li>자주 평가한 장르는 
          <c:forEach var="entry" items="${sortedGenreStats}" varStatus="loop">
            <c:if test="${entry.value > 0 && loop.index lt 3}">
              <strong>${entry.key}</strong>(${entry.value}회)<c:if test="${loop.index lt 2}">, </c:if>
            </c:if>
          </c:forEach>
          입니다.
        </li>
      </c:if>
    </ul>

    <p class="mt-3">
      <c:choose>
        <c:when test="${averageUserRating >= 7.5}">만족도가 높은 편이며 </c:when>
        <c:when test="${averageUserRating >= 6}">평균적인 만족도를 보이며 </c:when>
        <c:otherwise>다소 냉정한 평가 경향이 있으며 </c:otherwise>
      </c:choose>
      <c:choose>
        <c:when test="${averageViolenceScore >= 7}">폭력 수위가 높은 영화도 자주 감상하시는 경향이 있습니다.</c:when>
        <c:otherwise>비교적 폭력성이 낮은 영화를 선호하시는 편입니다.</c:otherwise>
      </c:choose>
    </p>

    <p class="text-muted">전반적으로 <strong>
      <c:choose>
        <c:when test="${positiveRatingTotal >= negativeRatingTotal * 2}">관대한 평가 경향</c:when>
        <c:when test="${positiveRatingTotal <= negativeRatingTotal}">엄격한 평가 경향</c:when>
        <c:otherwise>균형 잡힌 평가 경향</c:otherwise>
      </c:choose>
    </strong>을 보이십니다.</p>
  </div>
</div>

<!-- Bootstrap & Chart.js CDN -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!--  데이터 준비 -->
<script>
  const ratingLabels = [];
  const ratingValues = [];
  <c:forEach var="entry" items="${ratingCounts}">
    ratingLabels.push("${entry.key}점");
    ratingValues.push(${entry.value});
  </c:forEach>

  const genreLabels = [];
  const genreScores = [];
  <c:forEach var="entry" items="${genreAverageRatingMap}">
    <c:if test="${entry.value > 0}">
      genreLabels.push("${entry.key}");
      genreScores.push(${entry.value});
    </c:if>
  </c:forEach>
</script>

<!-- 차트 구역 (PC 중앙정렬, 모바일 정렬 유지) -->
<div class="container py-4">
  <h5 class="mb-3">📊 <strong>--</strong></h5>
  <hr>

  <div class="row justify-content-center text-center">
    <!-- 별점 분포 도넛 -->
    <div class="col-md-6 col-sm-12 mb-4">
      <canvas id="ratingDonutChart" style="max-width: 100%; height: auto;"></canvas>
    </div>

    <!-- 장르별 평균 별점 도넛 -->
    <div class="col-md-6 col-sm-12 mb-4">
      <canvas id="genreAverageChart" style="max-width: 100%; height: auto;"></canvas>
    </div>
  </div>
</div>

<!-- Chart.js-->
<script>
  document.addEventListener("DOMContentLoaded", function () {
    // 별점 도넛
    new Chart(document.getElementById('ratingDonutChart'), {
      type: 'doughnut',
      data: {
        labels: ratingLabels,
        datasets: [{
          label: '별점 분포',
          data: ratingValues,
          backgroundColor: [
            '#4e79a7', '#f28e2b', '#e15759', '#76b7b2',
            '#59a14f', '#edc949', '#af7aa1', '#ff9da7',
            '#9c755f', '#bab0ab'
          ]
        }]
      },
      options: {
        plugins: {
          title: { display: true, text: '별점 분포 (도넛형)', font: { size: 16 } },
          legend: { position: 'bottom' }
        }
      }
    });

    // 장르 도넛
    new Chart(document.getElementById('genreAverageChart'), {
      type: 'doughnut',
      data: {
        labels: genreLabels,
        datasets: [{
          label: '장르별 평균 별점',
          data: genreScores,
          backgroundColor: [
            '#4e79a7', '#f28e2b', '#e15759', '#76b7b2',
            '#59a14f', '#edc949', '#af7aa1', '#ff9da7',
            '#9c755f', '#bab0ab'
          ]
        }]
      },
      options: {
        plugins: {
          title: { display: true, text: '장르별 평균 별점 (도넛형)', font: { size: 16 } },
          legend: { position: 'bottom' }
        }
      }
    });
  });
</script>
