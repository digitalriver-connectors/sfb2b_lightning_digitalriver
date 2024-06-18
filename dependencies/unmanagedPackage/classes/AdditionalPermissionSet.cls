global with sharing class AdditionalPermissionSet {
    public AdditionalPermissionSet() {

        PermissionSet pr = new PermissionSet(Label='DRB2B Additional Permission set',Name='DRB2B_Additional_Permission_set');
        insert pr;
        System.debug('pr >'+pr);
        List<ObjectPermissions>  objectPermissionList = new List<ObjectPermissions>();

        ObjectPermissions objPermission = new ObjectPermissions();
        objPermission.PermissionsCreate=true;
        objPermission.PermissionsRead=true;
        objPermission.PermissionsEdit=true;
        objPermission.PermissionsDelete=true;
        objPermission.SobjectType='ORDER';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        objPermission = new ObjectPermissions();
        objPermission.PermissionsCreate=true;
        objPermission.PermissionsRead=true;
        objPermission.PermissionsEdit=true;
        objPermission.PermissionsDelete=true;
        objPermission.SobjectType='Ordersummary';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        objPermission = new ObjectPermissions();
        objPermission.PermissionsCreate=true;
        objPermission.PermissionsRead=true;
        objPermission.PermissionsEdit=true;
        objPermission.PermissionsDelete=true;
        objPermission.SobjectType='WebStore';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        objPermission = new ObjectPermissions();
        objPermission.PermissionsCreate=true;
        objPermission.PermissionsRead=true;
        objPermission.PermissionsEdit=true;
        objPermission.PermissionsDelete=true;
        objPermission.SobjectType='WebCart';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        objPermission = new ObjectPermissions();
        objPermission.PermissionsCreate=true;
        objPermission.PermissionsRead=true;
        objPermission.PermissionsEdit=true;
        objPermission.PermissionsDelete=true;
        objPermission.SobjectType='Product2';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        objPermission = new ObjectPermissions();
        objPermission.PermissionsRead=true;
        objPermission.SobjectType='Account';
        objPermission.ParentId = pr.Id;
        objectPermissionList.add(objPermission);

        insert objectPermissionList;
        List<FieldPermissions> fieldPermissionList = new List<FieldPermissions>();
        //OrderSummary Object fields 
        FieldPermissions fp= new FieldPermissions();
        //OrderItem Object fields 
        fp.Field='OrderItem.TotalTaxAmount';//the name of new field
        fp.ParentId = pr.Id;
        fp.PermissionsRead=true;
        fp.SobjectType='OrderItem';
        fieldPermissionList.add(fp);

        fp= new FieldPermissions();
        fp.Field='Product2.Productcode';//the name of new field
        fp.ParentId = pr.Id;
        fp.PermissionsEdit=true;//
        fp.PermissionsRead=true;
        fp.SobjectType='Product2';
        fieldPermissionList.add(fp);

        fp= new FieldPermissions();
        fp.Field='Product2.StockKeepingUnit';//the name of new field
        fp.ParentId = pr.Id;
        fp.PermissionsEdit=true;//
        fp.PermissionsRead=true;
        fp.SobjectType='Product2';
        fieldPermissionList.add(fp);

        fp= new FieldPermissions();
        fp.Field='Product2.DisplayUrl';//the name of new field
        fp.ParentId = pr.Id;
        fp.PermissionsEdit=true;//
        fp.PermissionsRead=true;
        fp.SobjectType='Product2';
        fieldPermissionList.add(fp);

        fp= new FieldPermissions();
        fp.Field='Product2.QuantityUnitOfMeasure';//the name of new field
        fp.ParentId = pr.Id;
        fp.PermissionsEdit=true;//
        fp.PermissionsRead=true;
        fp.SobjectType='Product2';
        fieldPermissionList.add(fp);

        Insert fieldPermissionList; 

        System.debug('fieldPermissionList >'+fieldPermissionList);

    }
}
