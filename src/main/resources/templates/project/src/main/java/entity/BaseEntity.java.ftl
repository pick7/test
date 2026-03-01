package ${packageName}.entity;

import jakarta.persistence.Column;
import jakarta.persistence.MappedSuperclass;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

/**
 * 通用审计字段基类。
 *
 * <p>用于承载 created_at / created_by / updated_at / updated_by，业务实体通过继承复用。
 */
@Getter
@Setter
@MappedSuperclass
public abstract class BaseEntity {

  @CreationTimestamp
  @Column(name = "created_at", nullable = false, updatable = false)
  private LocalDateTime createdAt;

  @Column(name = "created_by", nullable = false, updatable = false, length = 64)
  private String createdBy;

  @UpdateTimestamp
  @Column(name = "updated_at", nullable = false)
  private LocalDateTime updatedAt;

  @Column(name = "updated_by", nullable = false, length = 64)
  private String updatedBy;

  @PrePersist
  protected void prePersist() {
    if (createdBy == null || createdBy.isBlank()) {
      createdBy = "system";
    }
    if (updatedBy == null || updatedBy.isBlank()) {
      updatedBy = createdBy;
    }
  }

  @PreUpdate
  protected void preUpdate() {
    if (updatedBy == null || updatedBy.isBlank()) {
      updatedBy = "system";
    }
  }
}
