<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery CDN (AJAX 및 이벤트 핸들용) -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- Font Awesome 아이콘 (별 모양 표시용) -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

<!-- ⭐ 서버에서 전달된 영화 ID를 숨겨서 전달 (후속 AJAX 요청에 필요) -->
<input type="hidden" id="movieId" value="${movieId}" />

<textarea id="reviewContentInput" rows="4" cols="60" placeholder="리뷰를 작성하세요.">${myReview.reviewContent}</textarea>
<button id="saveReviewContentBtn">리뷰 저장</button>
<p>
  <strong>리뷰 : </strong>
  <c:choose>
    <c:when test="${not empty myReview.reviewContent}">
      ${myReview.reviewContent}
    </c:when>
    <c:otherwise>
      <span style="color:gray;">아직 리뷰를 작성하지 않으셨어요.</span>
    </c:otherwise>
  </c:choose>
</p>

<!-- ⭐ 서버로 전송 -->
<script>
document.getElementById("saveReviewContentBtn").addEventListener("click", function () {
    const content = document.getElementById("reviewContentInput").value.trim();
    const movieId = document.getElementById("movieId").value;

    if (content === "") {
        alert("리뷰 내용을 입력해주세요.");
        return;
    }

    const formData = new URLSearchParams();
    formData.append("movieId", movieId);
    formData.append("reviewContent", content);

    fetch("${pageContext.request.contextPath}/review/saveContent", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: formData
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert("리뷰가 저장되었습니다.");
        } else {
            alert(data.message || "저장 실패");
        }
    })
    .catch(err => {
        console.error("저장 오류:", err);
    });
});

</script>