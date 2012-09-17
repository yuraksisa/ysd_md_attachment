YSD_MD_ATTACHMENT
=================

<p>It allows to improve your (DataMapper or Persistence) models with attachments.</p>
<p>Attachments are stored in a Storage. An storage uses adapters to manage the files. In this release, we have included an storage to Google Drive. In the feature will be available storages for Dropbox and file system.</p>

<h2>How to use it</h2>

<p>Steps:</p>

<ol>
  <li>Define an storage</li>
  <li>Improve your classes using an include</li>
  <li>Attach files to your objects</li>
</ol>

<h3>Define an storage</h3>

<h3>Improve your classes</h3>
<p>If your class extends Persistence::Resource, include Model::AttachmentPersistence to allow the management of file attachments to the resource</p>
<p>If your class extends DataMapper::Resource, include Model::AttachmentDataMapper to allow the management of file attachemnts to the resource</p>

<h3>Manage the attachements</h3>
<p>Then, you can use the following methods to manage the attachments:</p>

<ul>
  <li>attach_from_file(storage, remote_path, local_file_path)</li>
  <li>attach_from_io(storage, remote_path, io, file_size)</li>
  <li>dettach(id)</li>
  <li>get_attachments</li>
</ul>

<p>Each attachment is an instance of Model::FileAttachment</p>

<h2>API</h2>

<ul>
  <li>Model::FileAttachment</li>
  <li>Model::Storage</li>
</ul>

<h3>Model::Storage</h3>
<h3>Model::FileAttachment</h3>
