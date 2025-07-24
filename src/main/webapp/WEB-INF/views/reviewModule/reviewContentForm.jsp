<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<!-- 영화 ID -->
<input type="hidden" id="movieId" value="${movieId}" />
<c:if test="${not empty loginMember}">
    <input type="hidden" id="memberId" value="${loginMember.id}" />
</c:if>

<!-- 부트스트랩 CSS 추가 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- 리뷰 작성창 -->
<div id="reviewWriteBox" class="mb-4" <c:if test="${not empty myReview.reviewContent}">style="display:none;"</c:if>>
  <textarea class="form-control border-0 border-bottom rounded-0 px-0" 
            id="reviewContentInput" 
            rows="4" 
            placeholder="아직 리뷰를 남기지 않으셨어요." 
            style="resize: none; background-color: transparent;"></textarea>
  <div class="text-end mt-2">
    <button class="btn btn-dark btn-sm" id="saveReviewContentBtn">리뷰 저장</button>
  </div>
</div>

<!-- 리뷰 출력창 -->
<div id="reviewDisplayBox" class="mb-4" <c:if test="${empty myReview.reviewContent}">style="display:none;"</c:if>>
  <div id="reviewContentBox" class="mb-2" style="white-space: pre-wrap;">
    ${fn:escapeXml(myReview.reviewContent)}
  </div>
  <div class="text-end">
    <button class="btn btn-outline-secondary btn-sm me-2" id="editReviewBtn">수정</button>
    <button class="btn btn-outline-danger btn-sm" id="deleteReviewBtn">삭제</button>
  </div>
</div>

  <!-- 비로그인 시 안내 -->
  <c:if test="${empty loginMember}">
    <div class="alert alert-light text-secondary mt-2" role="alert">
      리뷰를 작성하시려면 로그인해주세요.
    </div>
  </c:if>
</div>

<!-- JS -->
<script>
document.addEventListener("DOMContentLoaded", function () {
    const content = "${fn:escapeXml(myReview.reviewContent)}";
    const input = document.getElementById("reviewContentInput");
    if (input && content.trim() !== "") {
        input.value = content;
    }

    const saveBtn = document.getElementById("saveReviewContentBtn");
    const editBtn = document.getElementById("editReviewBtn");
    const deleteBtn = document.getElementById("deleteReviewBtn");

    // 저장
    if (saveBtn) {
        saveBtn.addEventListener("click", function () {
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
                    document.getElementById("reviewText").textContent = content;
                    document.getElementById("reviewWriteBox").style.display = "none";
                    document.getElementById("reviewDisplayBox").style.display = "block";
                } else {
                    alert(data.message || "저장 실패");
                }
            });
        });
    }

    // 수정
    if (editBtn) {
        editBtn.addEventListener("click", function () {
            document.getElementById("reviewWriteBox").style.display = "block";
            document.getElementById("reviewDisplayBox").style.display = "none";
        });
    }

    // 삭제
    if (deleteBtn) {
        deleteBtn.addEventListener("click", function () {
            if (!confirm("정말 리뷰를 삭제하시겠습니까?")) return;

            const movieId = document.getElementById("movieId").value;

            fetch("${pageContext.request.contextPath}/review/deleteReview", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: new URLSearchParams({ movieId })
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    alert("삭제되었습니다.");
                    document.getElementById("reviewWriteBox").style.display = "block";
                    document.getElementById("reviewDisplayBox").style.display = "none";
                    document.getElementById("reviewContentInput").value = "";
                } else {
                    alert(data.message || "삭제 실패");
                }
            });
        });
    }
});
</script>
