package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Supplier implements Serializable {
    private static final long serialVersionUID = 1L;

    private int supplierId;
    private String supplierCode;
    private String supplierName;
    private String contactPhone;
    private String address;
    private String status;
    private Timestamp createdAt;

    public Supplier() {
        this.status = "ACTIVE";
    }

    public Supplier(int supplierId, String supplierCode, String supplierName, String contactPhone, String address, String status, Timestamp createdAt) {
        this.supplierId = supplierId;
        this.supplierCode = supplierCode;
        this.supplierName = supplierName;
        this.contactPhone = contactPhone;
        this.address = address;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getSupplierId() {
        return supplierId;
    }

    public void setSupplierId(int supplierId) {
        this.supplierId = supplierId;
    }

    public String getSupplierCode() {
        return supplierCode;
    }

    public void setSupplierCode(String supplierCode) {
        this.supplierCode = supplierCode;
    }

    public String getSupplierName() {
        return supplierName;
    }

    public void setSupplierName(String supplierName) {
        this.supplierName = supplierName;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}

